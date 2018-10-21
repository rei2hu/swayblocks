defmodule BlocksLogger do
  @moduledoc """
  Several methods for logging to stderr
  """

  defp put(content, level) when is_binary(content) do
    IO.puts(:stderr, "#{time()} #{level} #{content}")
  end

  defp put(content, level) do
    IO.puts(:stderr, "#{time()} #{level} #{inspect(content)}")
  end

  def warn(content) do
    put(content, "[WARN]")
  end

  def info(content) do
    put(content, "[INFO]")
  end

  defp time() do
    {{_yr, _m, _d}, {hr, min, sec}} = :calendar.local_time()

    [hr, min, sec]
    |> Enum.map_join(":", fn x -> x |> Integer.to_string() |> String.pad_leading(2, "0") end)
    |> (fn x -> "[" <> x <> "]" end).()
  end
end
