defmodule Bark.LogFormatterTest do
  use ExUnit.Case, async: true

  describe "Bark.LogFormatter" do
    test "format works" do
      # https://hexdocs.pm/logger/1.17.3/Logger.html#module-metadata
      metadata = [
        mfa: {Bark.LogFormatter, :format, 4},
        line: 42,
        file: "lib/log_formatter.ex",
        some_other_key: "it works with \"escaped\" strings as well"
      ]

      date = {2025, 8, 11}
      time_ms = {14, 45, 0, 0}

      logged_string =
        IO.chardata_to_string(
          Bark.LogFormatter.format(
            :info,
            "This is a test message",
            {date, time_ms},
            metadata
          )
        )

      assert logged_string =~ "14:45:00.000"
      assert logged_string =~ "module=Bark.LogFormatter"
      assert logged_string =~ "command=format/4"
      assert logged_string =~ "some_other_key=\"it works with ″escaped″ strings as well\""
      assert logged_string =~ "[info]"
      assert logged_string =~ "This is a test message\n"
    end

    test "format doesn't crash on missing metadata" do
      metadata = []

      date = {2025, 8, 11}
      time_ms = {14, 45, 0, 0}

      logged_string =
        IO.chardata_to_string(
          Bark.LogFormatter.format(
            :info,
            "This is a test message",
            {date, time_ms},
            metadata
          )
        )

      assert logged_string =~ "14:45:00.000"
      assert logged_string =~ "[info]"
      assert logged_string =~ "This is a test message\n"
    end
  end
end
