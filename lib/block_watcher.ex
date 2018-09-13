defmodule BlockWatcher do
  def update(name) do
    {blocks, 0} = System.cmd(Path.expand(name), [])

    blocks
    |> String.split("\n")
    |> handle_blocks(name)
  end

  defp handle_blocks(list, name) do
    case list do
      [] ->
        []

      [head | tail] when head !== "" ->
        [handle_block(head, name) | handle_blocks(tail, name)]

      [_ | tail] ->
        handle_blocks(tail, name)
    end
  end

  defp handle_block(list, name) do
    String.split(list, "///")
    |> Enum.reduce(%{}, fn e, acc ->
      case String.split(e, ":", parts: 2) do
        [key, value] ->
          Map.put(acc, key, value)

        _ ->
          nil
      end
    end)
    |> Map.put("name", name)
    |> Poison.encode()
    |> check_output
  end

  defp check_output(encoded) do
    case encoded do
      {:ok, json} ->
        json

      _ ->
        nil
    end
  end
end
