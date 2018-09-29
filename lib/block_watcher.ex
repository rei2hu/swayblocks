defmodule BlockWatcher do
  @moduledoc """
  Handles script output for blocks
  """

  @doc """
  Runs a script and decodes it

  Returns list_of_maps
  """
  def update(name, default) do
    {blocks, 0} = System.cmd(Path.expand(name), [])

    blocks
    |> String.split("\n")
    |> handle_blocks(name, default, 0)
  end

  defp handle_blocks(list, name, default, instance) do
    case list do
      [] ->
        []

      [head | tail] when head !== "" ->
        [
          handle_block(head, name, default, instance)
          | handle_blocks(tail, name, default, instance + 1)
        ]

      [_ | tail] ->
        handle_blocks(tail, name, default, instance)
    end
  end

  defp handle_block(list, name, default, instance) do
    String.split(list, "///")
    |> Enum.reduce(%{}, fn e, acc ->
      case String.split(e, ":", parts: 2) do
        [key, value] ->
          Map.put(acc, key, value)

        _ ->
          acc
      end
    end)
    |> Map.put("name", name)
    |> Map.put("instance", instance)
    |> Enum.into(default)
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
