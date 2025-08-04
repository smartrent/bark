defmodule BarkTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  require Bark

  describe "Bark" do
    test "can log metadata of type: keyword list" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log(fn -> Bark.info(opts) end)

      assert_log_output(log_output, :info, IO.ANSI.normal(), opts)
    end

    test "can log metadata of type: list of two-element tuples" do
      opts = [{"key", "key"}, {"message", "oh no"}, {"user_id", 456}, {"action", "login"}]

      log_output = capture_log(fn -> Bark.info(opts) end)

      assert_log_output(log_output, :info, IO.ANSI.normal(), opts)
    end

    test "can log with opts[:ansi_color]" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      # Test with valid color
      log_output = capture_log(fn -> Bark.info(opts ++ [ansi_color: :yellow]) end)

      assert_log_output(log_output, :info, IO.ANSI.yellow(), opts)

      # Test with invalid color - should not crash
      log_output = capture_log(fn -> Bark.info(opts ++ [ansi_color: :invalid_color]) end)

      assert_log_output(log_output, :info, IO.ANSI.normal(), opts)
    end

    test "debug logs at debug level" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log([level: :debug], fn -> Bark.debug(opts) end)

      assert_log_output(log_output, :debug, IO.ANSI.cyan(), opts)
    end

    test "info logs at info level" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log([level: :info], fn -> Bark.info(opts) end)

      assert_log_output(log_output, :info, IO.ANSI.normal(), opts)
    end

    test "audit logs at notice level" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log([level: :notice], fn -> Bark.audit(opts) end)

      assert_log_output(log_output, :notice, IO.ANSI.normal(), opts)
    end

    test "warn logs at warning level" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log([level: :warning], fn -> Bark.warn(opts) end)

      assert_log_output(log_output, :warning, IO.ANSI.yellow(), opts)
    end

    test "error" do
      opts = [key: "key", message: "oh no", user_id: 123, action: "login"]

      log_output = capture_log([level: :error], fn -> Bark.error(opts) end)

      assert_log_output(log_output, :error, IO.ANSI.red(), opts)
    end
  end

  defp assert_log_output(output, level_atom, ansi_color, opts) do
    assert output =~ "[#{level_atom}]"
    assert output =~ ansi_color

    Enum.each(opts, fn pair ->
      assert output =~ opt_pair_to_string(pair)
    end)

    assert output =~ IO.ANSI.reset()
  end

  defp opt_pair_to_string({key, value}) when is_binary(value) do
    value =
      case String.split(value, " ") do
        [one] when is_binary(one) -> one
        _ -> "\"#{value}\""
      end

    "#{key}=#{value}"
  end

  defp opt_pair_to_string({key, value}) do
    "#{key}=#{value}"
  end
end
