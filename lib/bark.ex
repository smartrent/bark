defmodule Bark do
  @moduledoc """
  `Bark` is a wrapper around `Logger` that adds context and standard formatting to your logs.
  """

  require Logger

  @spec warn(Macro.Env.t(), Keyword.t()) :: :ok
  def warn(env, opts),
    do:
      Logger.warning(parse_message(env, opts), ansi_color: validate_ansi_color(opts[:ansi_color]))

  @spec info(Macro.Env.t(), Keyword.t()) :: :ok
  def info(env, opts),
    do: Logger.info(parse_message(env, opts), ansi_color: validate_ansi_color(opts[:ansi_color]))

  @spec audit(Macro.Env.t(), Keyword.t()) :: :ok
  def audit(env, opts),
    do:
      Logger.notice(parse_message(env, opts), ansi_color: validate_ansi_color(opts[:ansi_color]))

  @spec error(Macro.Env.t(), Keyword.t()) :: :ok
  def error(env, opts),
    do: Logger.error(parse_message(env, opts), ansi_color: validate_ansi_color(opts[:ansi_color]))

  @spec debug(Macro.Env.t(), Keyword.t()) :: :ok
  def debug(env, opts),
    do: Logger.debug(parse_message(env, opts), ansi_color: validate_ansi_color(opts[:ansi_color]))

  @valid_colors [
    :black,
    :red,
    :green,
    :yellow,
    :blue,
    :magenta,
    :cyan,
    :white,
    :light_black,
    :light_red,
    :light_green,
    :light_yellow,
    :light_blue,
    :light_magenta,
    :light_cyan,
    :light_white,
    :black_background,
    :red_background,
    :green_background,
    :yellow_background,
    :blue_background,
    :magenta_background,
    :cyan_background,
    :white_background,
    :light_black_background,
    :light_red_background,
    :light_green_background,
    :light_yellow_background,
    :light_blue_background,
    :light_magenta_background,
    :light_cyan_background,
    :light_white_background
  ]

  defp validate_ansi_color(color) when color in @valid_colors, do: color
  defp validate_ansi_color(_), do: nil

  defp parse_message(env, opts) when is_list(opts) do
    opts = Keyword.drop(opts, [:ansi_color])

    env
    |> add_caller_context(opts)
    |> to_log_formatted_string()
  end

  defp to_log_formatted_string(keywords) do
    keywords
    |> Enum.map(fn {key, value} ->
      "#{log_value(key)}=#{log_value(value)}"
    end)
    |> Enum.join(" ")
  end

  defp add_caller_context(env, opts) when is_list(opts) do
    opts
    |> Keyword.put_new(:line, line_number(env))
    |> Keyword.put_new(:command, function_name_arity(env))
    |> Keyword.put_new(:module, module(env))
  end

  defp module(%{:module => module} = _env) when is_atom(module) do
    module
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end

  defp module(_), do: "None"

  defp function_name_arity(%{:function => {function_name, arity}}),
    do: "#{function_name}/#{arity}"

  defp function_name_arity(_), do: "None"

  defp line_number(%{line: line}), do: line
  defp line_number(not_line), do: inspect(not_line)

  # Quote string if it contains a space, and if there are quotes within in the string replace them with something that
  # doesn't break the parser.
  defp quote_if_spaces(value) when is_binary(value) do
    if String.contains?(value, " ") do
      value_with_escaped_quotes = String.replace(value, "\"", "″")
      "\"#{value_with_escaped_quotes}\""
    else
      value
    end
  end

  # A safeguard if for some reason inspect doesn't return a binary we dont crash trying to log it.
  defp quote_if_spaces(_unexpected), do: ""

  defp log_value(value) when is_binary(value), do: quote_if_spaces(value)
  defp log_value(value) when is_atom(value), do: Atom.to_string(value)
  defp log_value(value), do: quote_if_spaces(inspect(value))
end
