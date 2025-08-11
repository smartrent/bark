defmodule Bark.LogFormatter do
  @moduledoc """
  To use in an application, add this in `config/`

  ```elixir
  config :logger, :console, format: "..."

  # Pulls the format string from existing console logger, or uses a default
  config :logger, :default_formatter,
      format: {Bark.LogFormatter, :format},
  ```

  https://hexdocs.pm/logger/1.17.3/Logger.Formatter.html#module-formatting-function
  """

  @default_format "$time $metadata[$level] $message\n"
  @format :logger
          |> Application.compile_env(:console, [])
          |> Keyword.get(:format, @default_format)

  @spec format(atom, IO.chardata(), Logger.Formatter.date_time_ms(), keyword()) :: IO.chardata()
  def format(level, message, timestamp, metadata) do
    metadata = metadata |> format_metadata() |> escape_values()

    Logger.Formatter.format(
      Logger.Formatter.compile(@format),
      level,
      message,
      timestamp,
      metadata
    )
  end

  # In order to not break existing DataDog log queries for logs in DataDog,
  # we have to match the same log/metadata format as defined in Bark.parse_message
  # we manually
  defp format_metadata(metadata) do
    case Keyword.get(metadata, :mfa) do
      {module, function, arity} ->
        module = module |> Atom.to_string() |> String.replace("Elixir.", "")
        command = "#{function}/#{arity}"

        metadata
        |> Keyword.put_new(:module, module)
        |> Keyword.put_new(:command, command)

      _ ->
        metadata
    end
  end

  defp escape_values(metadata) do
    Enum.map(metadata, fn {key, value} ->
      {maybe_escape(key), maybe_escape(value)}
    end)
  end

  defp maybe_escape(value) when is_atom(value), do: Atom.to_string(value)
  defp maybe_escape(value) when is_binary(value), do: escape_space_separated_string(value)
  defp maybe_escape(value), do: value

  # Quote string if it contains a space and there are quotes within in the string,
  # replace them with something that doesn't break the DataDog parser.
  defp escape_space_separated_string(value) when is_binary(value) do
    if String.contains?(value, " ") do
      value_without_escaped_quotes = String.replace(value, "\"", "″")
      "\"#{value_without_escaped_quotes}\""
    else
      value
    end
  end
end
