defmodule PosthogTest do
  use ExUnit.Case
  doctest Posthog

  test "greets the world" do
    assert Posthog.hello() == :world
  end
end
