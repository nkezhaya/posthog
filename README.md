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

Optionally, you can pass in a `:json_library` key. The default JSON parser is Jason.

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
