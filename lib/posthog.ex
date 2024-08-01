defmodule Posthog do
  @moduledoc """
  This module provides an Elixir HTTP client for Posthog.

  Example config:

      config :posthog,
        api_url: "http://posthog.example.com",
        api_key: "..."

  Optionally, you can pass in a `:json_library` key. The default JSON parser
  is Jason.
  """

  @doc """
  Sends a capture event. `distinct_id` is the only required parameter.

  ## Examples

      iex> Posthog.capture("login", distinct_id: user.id)
      :ok
      iex> Posthog.capture("login", [distinct_id: user.id], DateTime.utc_now())
      :ok
      iex> Posthog.capture("login", [distinct_id: user.id], [headers: [{"x-forwarded-for", "127.0.0.1"}]])

  """
  @typep result() :: {:ok, term()} | {:error, term()}
  @typep timestamp() :: DateTime.t() | NaiveDateTime.t() | String.t() | nil

  @spec capture(atom() | String.t(), keyword() | map(), keyword() | timestamp()) :: result()
  defdelegate capture(event, params, opts \\ nil), to: Posthog.Client

  @spec batch(list(tuple()), keyword()) :: result()
  defdelegate batch(events, opts \\ nil), to: Posthog.Client

  @spec feature_flags(term(), keyword()) :: result()
  defdelegate feature_flags(distinct_id, opts \\ []), to: Posthog.Client
end
