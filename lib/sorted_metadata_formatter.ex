defmodule Bark.SortedMetadataFormatter do
  @moduledoc """
  Custom logger formatter that sorts metadata keys alphabetically.

  https://hexdocs.pm/logger/Logger.Formatter.html
  """

  require Logger

  @default_format "[$level] $message\n"

  @doc """
  ## Examples

      iex> Bark.SortedMetadataFormatter.format(:info, "hello", DateTime.utc_now(), [key: "hello", c: "c", d: "d", z: "z", a: "a"])
      ["[", "info", "] ", "a=a c=c d=d key=hello z=z hello", "\n"]
  """
  @spec format(atom(), IO.chardata(), Logger.Formatter.date_time_ms(), keyword()) :: IO.chardata()
  def format(level, message, timestamp, metadata) when is_binary(message) do
    if String.contains?(message, "key=") do
      format_sorted_message_metadata(level, message, timestamp, metadata)
    else
      Logger.Formatter.format(
        Logger.Formatter.compile(@default_format),
        level,
        timestamp,
        timestamp,
        metadata
      )
      |> dbg()
    end
  end

  def format(level, message, timestamp, metadata) do
    dbg(message)

    Logger.Formatter.format(
      Logger.Formatter.compile(@default_format),
      level,
      message,
      timestamp,
      metadata
    )
  end

  defp format_sorted_message_metadata(level, message, timestamp, _metadata) do
    {metadata, message} =
      message
      |> String.split(" ")
      |> Enum.split_with(fn piece -> String.contains?(piece, "=") end)

    metadata =
      Enum.map(metadata, fn string_pair ->
        # Split each pair by "=" into a key and a value
        [key, value] = String.split(string_pair, "=", parts: 2)
        {String.to_existing_atom(key), value}
      end)

    # Display the key first regardless of alphabetical order
    {key, metadata} = Keyword.pop(metadata, :key)
    {module, metadata} = Keyword.pop(metadata, :module)
    {command, metadata} = Keyword.pop(metadata, :command)
    {line, metadata} = Keyword.pop(metadata, :line)

    first_meta =
      [
        key: key,
        module: module,
        command: command,
        line: line
      ]
      |> Enum.reject(fn {_, value} -> is_nil(value) end)
      |> Enum.map(fn
        {:key, value} ->
          IO.ANSI.format([:cyan, "key=#{value}"])

        {key, value} ->
          "#{key}=#{value}"
      end)
      |> Enum.join(" ")

    sorted_metadata =
      metadata
      |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
      |> Enum.map(fn {key, value} ->
        "#{key}=#{value}"
      end)
      |> Enum.join(" ")

    Logger.Formatter.format(
      Logger.Formatter.compile(@default_format),
      level,
      "#{first_meta} #{sorted_metadata} #{message}",
      timestamp,
      []
    )
  end
end
