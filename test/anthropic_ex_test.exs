defmodule AnthropicExTest do
  use ExUnit.Case
  doctest AnthropicEx

  test "greets the world" do
    assert AnthropicEx.hello() == :world
  end
end
