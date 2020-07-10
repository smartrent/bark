defmodule LogTest do
  use ExUnit.Case
  doctest Log

  test "greets the world" do
    assert Log.hello() == :world
  end
end
