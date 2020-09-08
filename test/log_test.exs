defmodule LogTest do
  use ExUnit.Case, async: true
  doctest Bark

  describe "info" do
    test "can log a list of keywords" do
      assert Bark.info(__ENV__,
               speak: "woof",
               number: 1,
               map: %{something: "neet"},
               tuple: {:tuple, :ok}
             ) == :ok
    end
  end

  describe "warn" do
    test "can log a list of keywords" do
      assert Bark.warn(__ENV__,
               speak: "woof",
               number: 1,
               map: %{something: "neet"},
               tuple: {:tuple, :ok}
             ) == :ok
    end
  end

  describe "error" do
    test "can log a list of keywords" do
      assert Bark.error(__ENV__,
               speak: "woof",
               number: 1,
               map: %{something: "neet"},
               tuple: {:tuple, :ok}
             ) == :ok
    end
  end

  describe "debug" do
    test "can log a list of keywords" do
      assert Bark.debug(__ENV__,
               speak: "woof",
               number: 1,
               map: %{something: "neet"},
               tuple: {:tuple, :ok}
             ) == :ok
    end
  end
end
