# Posthog

This library provides an HTTP client for Posthog.

## Installation

The package can be installed by adding `posthog` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:posthog, "~> 0.2"}
  ]
end
```

## Configuration

```elixir
config :posthog,
  api_url: "http://posthog.example.com",
  api_key: "..."
```

You can pass in a `:json_library` key. The default JSON parser is Jason.

You can pass in a `:version` key. The default version is 3 (which is currently the latest).

## Usage

Capturing events:

```elixir
Posthog.capture("login", distinct_id: user.id)
```

Specifying additional headers:

```elixir
Posthog.capture("login", [distinct_id: user.id], [headers: [{"x-forwarded-for", "127.0.0.1"}]])
```

Capturing multiple events:

```elixir
Posthog.batch([{"login", [distinct_id: user.id], nil}])
```

Fetching all matched feature flags for identifier:

```elixir
Posthog.feature_flags("distinct-id")

{:ok,
 %{
   "featureFlagPayloads" => %{
     "feature-1" => 1,
     "feature-2" => %{"variant-1" => "value-1", "variant-2" => "value-2"}
   },
   "featureFlags" => %{"feature-1" => true, "feature-2" => "variant-2"}
 }}
```

Fetching match information for a feature flag:

```elixir
# For boolean feature flags
Posthog.feature_flag("feature-1", "matching-id")

{:ok,
 %Posthog.FeatureFlag{
   name: "feature-1",
   value: 1,
   enabled: true
 }}

 Posthog.feature_flag("feature-1", "non-matching-id")

{:ok,
 %Posthog.FeatureFlag{
   name: "feature-1",
   value: nil,
   enabled: false
 }}

# For multivariate feature flags
Posthog.feature_flag("feature-2", "distinct-id")

{:ok,
 %Posthog.FeatureFlag{
   name: "feature-2",
   value: %{"variant-1" => "value-1", "variant-2" => "value-2"},
   enabled: "variant-2"
 }}

 # For non-existent or disabled feature flags
 {:error, :not_found}
```

Checking if feature flag is enabled:

```elixir
Posthog.feature_flag_enabled?("feature-2", "distinct-id")

true
```