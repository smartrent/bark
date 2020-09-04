defmodule Bark do
  require Logger

  # Logs a list of kv pairs
  @spec warn(any(), Keyword.t() | binary()) :: any()
  def warn(env, opts), do: Logger.warn(parse_message(env, opts))

  @spec info(any(), Keyword.t() | binary()) :: any()
  def info(env, opts), do: Logger.info(parse_message(env, opts))

  @spec error(any(), Keyword.t() | binary()) :: any()
  def error(env, opts), do: Logger.error(parse_message(env, opts))

  @spec debug(any(), Keyword.t() | binary()) :: any()
  def debug(env, opts), do: Logger.debug(parse_message(env, opts))

  defp parse_message(env, opts) when is_list(opts) do
    env
    |> add_caller_context(opts)
    |> Enum.map(fn {key, value} ->
        "#{Atom.to_string(key)}=#{log_value(value)}"
      end)
    |> Enum.join(" ")
  end

  defp parse_message(env, opts) when is_binary(opts) do
    %{message: opts}
    |> add_caller_context(opts)
  end

  defp add_caller_context(env, opts) when is_list(opts) do
    opts
    |> Keyword.put_new(:line, line_number(env))
    |> Keyword.put_new(:command, function_name_arity(env))
    |> Keyword.put_new(:module, module(env))
  end

  defp module(%{:module => module} = _env ) when is_atom(module) do
    module
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end
  defp module(_), do: "None"

  defp function_name_arity(%{:function => {function_name, arity}}), do: "#{function_name}/#{arity}"
  defp function_name_arity(_), do: "None"

  defp line_number(%{line: line}), do: line
  defp line_number(not_line), do: inspect(not_line)

  # Quote string if it contains a space
  defp quote_if_spaces(value) when is_binary(value) do
    if String.contains?(value, " ") do
      value_with_escaped_quotes = String.replace(value, "\"", "\\\"" )
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
