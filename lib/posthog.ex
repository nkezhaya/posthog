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

  alias Posthog.{Client, FeatureFlag}

  @spec capture(atom() | String.t(), keyword() | map(), keyword() | timestamp()) :: result()
  defdelegate capture(event, params, opts \\ []), to: Client

  @spec batch(list(tuple()), keyword()) :: result()
  defdelegate batch(events, opts \\ []), to: Client

  @spec feature_flags(binary(), keyword()) :: result()
  defdelegate feature_flags(distinct_id, opts \\ []), to: Client

  @spec feature_flag(binary(), binary(), keyword()) :: result()
  def feature_flag(flag, distinct_id, opts \\ []) do
    with {:ok, %{"featureFlags" => flags} = result} <- feature_flags(distinct_id, opts),
         enabled when not is_nil(enabled) <- flags[flag] do
      {:ok, FeatureFlag.new(flag, enabled, get_in(result, ["featureFlagPayloads", flag]))}
    else
      {:error, _} = err -> err
      nil -> {:error, :not_found}
    end
  end

  @spec feature_flag_enabled?(binary(), binary(), keyword()) :: boolean()
  def feature_flag_enabled?(flag, distinct_id, opts \\ []) do
    flag
    |> feature_flag(distinct_id, opts)
    |> case do
      {:ok, %FeatureFlag{enabled: false}} -> false
      {:ok, %FeatureFlag{}} -> true
      _ -> false
    end
  end
end
