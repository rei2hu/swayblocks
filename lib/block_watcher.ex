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

  def update(name) do
    name = name |> Atom.to_string()
    {blocks, 0} = System.cmd(System.cwd() <> "/" <> name, [])

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
