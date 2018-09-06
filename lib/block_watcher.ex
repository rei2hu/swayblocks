defmodule BlockWatcher do
  use GenServer

  def start_link(block) do
    GenServer.start_link(__MODULE__, block, name: block)
  end

  @impl true
  def init(block) do
    # get first setup
    state =
      %{:name => block, :blocks => []}
      |> update

    {:ok, state}
  end

  @impl true
  def handle_call(:update, _from, state) do
    case newstate = update(state) do
      :err ->
        {:reply, :err, newstate}

      _ ->
        {:reply, newstate, newstate}
    end
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  defp update(state) do
    parent = self()
    block = state[:name] |> Atom.to_string()
    spawn(fn -> send(parent, System.cmd("bash", [block])) end)

    receive do
      # good response
      {blocks, 0} ->
        blocks
        |> String.split("\n")
        |> handle_blocks
        |> (&Map.put(state, :blocks, &1)).()

      # bad block response
      _ ->
        nil
    after
      # 500ms timeout
      500 ->
        nil
    end
  end

  defp handle_blocks(list) do
    case list do
      [] ->
        []

      [head | tail] when head !== "" ->
        [handle_block(head) | handle_blocks(tail)]

      [_ | tail] ->
        handle_blocks(tail)
    end
  end

  defp handle_block(list) do
    String.split(list, "///")
    |> Enum.reduce(%{}, fn e, acc ->
      case String.split(e, ":", parts: 2) do
        [key, value] ->
          Map.put(acc, key, value)

        _ ->
          nil
      end
    end)
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
