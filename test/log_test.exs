defmodule LogTest do
  use ExUnit.Case, async: true
  doctest Bark

  describe "info" do
    test "greets the world" do
      assert Bark.info(__ENV__, speak: "woof", number: 1, map: %{something: "neet"}, tuple: {:tuple, :ok} ) == :ok
    end
  end

  describe "warn" do
    test "greets the world" do
      assert Bark.warn(__ENV__, speak: "woof", number: 1, map: %{something: "neet"}, tuple: {:tuple, :ok} ) == :ok
    end
  end

  describe "error" do
    test "greets the world" do
      assert Bark.error(__ENV__, speak: "woof", number: 1, map: %{something: "neet"}, tuple: {:tuple, :ok} ) == :ok
    end
  end

  describe "debug" do
    test "greets the world" do
      assert Bark.debug(__ENV__, speak: "woof", number: 1, map: %{something: "neet"}, tuple: {:tuple, :ok} ) == :ok
    end
  end
end
