defmodule Posthog.Client do
  @moduledoc false
  @app :posthog

  defp headers(additional_headers \\ []) do
    Enum.concat(additional_headers || [], [{"content-type", "application/json"}])
  end

  def capture(event, params, opts) when is_list(opts) do
    post!("/capture", build_event(event, params, opts[:timestamp]), headers(opts[:headers]))
  end

  def capture(event, params, timestamp) when is_bitstring(event) or is_atom(event) do
    post!("/capture", build_event(event, params, timestamp), headers())
  end

  def batch(events, opts) when is_list(opts) do
    batch(events, opts, headers(opts[:headers]))
  end

  def batch(events, _opts, headers) do
    body = for {event, params, timestamp} <- events, do: build_event(event, params, timestamp)

    post!("/capture", %{batch: body}, headers)
  end

  defp build_event(event, properties, timestamp) do
    %{event: to_string(event), properties: Map.new(properties), timestamp: timestamp}
  end

  defp post!(path, %{} = body, headers) do
    body =
      body
      |> Map.put(:api_key, api_key())
      |> json_library().encode!()

    api_url()
    |> URI.merge(path)
    |> URI.append_query("v=#{api_version()}")
    |> URI.to_string()
    |> :hackney.post(headers, body)
    |> handle()
  end

  @spec handle(tuple()) :: {:ok, term()} | {:error, term()}
  defp handle({:ok, status, _headers, _ref} = resp) when div(status, 100) == 2 do
    {:ok, to_response(resp)}
  end

  defp handle({:ok, _status, _headers, _ref} = resp) do
    {:error, to_response(resp)}
  end

  defp handle({:error, _} = result) do
    result
  end

  defp to_response({_, status, headers, ref}) do
    response = %{status: status, headers: headers, body: nil}

    with {:ok, body} <- :hackney.body(ref),
         {:ok, json} <- json_library().decode(body) do
      %{response | body: json}
    else
      _ -> response
    end
  end

  defp api_url do
    case Application.get_env(@app, :api_url) do
      url when is_bitstring(url) ->
        url

      term ->
        raise """
        Expected a string API URL, got: #{inspect(term)}. Set a
        URL and key in your config:

            config :posthog,
              api_url: "https://posthog.example.com",
              api_key: "my-key"
        """
    end
  end

  defp api_key do
    case Application.get_env(@app, :api_key) do
      key when is_bitstring(key) ->
        key

      term ->
        raise """
        Expected a string API key, got: #{inspect(term)}. Set a
        URL and key in your config:

            config :posthog,
              api_url: "https://posthog.example.com",
              api_key: "my-key"
        """
    end
  end

  defp json_library do
    Application.get_env(@app, :json_library, Jason)
  end

  defp api_version do
    Application.get_env(@app, :version, 3)
  end
end
