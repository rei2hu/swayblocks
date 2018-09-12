defmodule Updater do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :Updater)
  end

  @impl true
  def init(files) do
    state =
      files
      |> Enum.map(fn x ->
        case x do
          {a, b} -> {Path.expand(a), b, nil}
          {a, b, c} -> {Path.expand(a), b, Path.expand(c)}
        end
      end)
      |> Enum.map_reduce(%{}, fn x, acc ->
        {name, time, click} = x

        {name, Map.put(acc, name, %{:click => click, :time => time, :left => 0, :content => nil})}
      end)

    send(self(), :start)

    {:ok, state}
  end

  @impl true
  def handle_call({:click, clickmap}, _from, state) do
    {order, files} = state

    files = handle_click(files, clickmap)
    send(self(), {:checkupdate, 0, false})

    {:reply, :ok, {order, files}}
  end

  defp handle_click(files, clickmap) do
    key = clickmap["name"]
    %{^key => map} = files

    case map[:click] do
      nil ->
        files

      script ->
        {:ok, str} = Poison.encode(clickmap)
        System.cmd(script, [str])
        Map.put(files, key, Map.put(map, :left, 0))
    end
  end

  defp update_contents(file) do
    Task.async(fn -> {file, BlockWatcher.update(file)} end)
  end

  @impl true
  def handle_info(:start, state) do
    IO.puts("{\"version\":1,\"click_events\":true}")
    IO.puts("[")
    send(self(), {:checkupdate, 0, true})
    {:noreply, state}
  end

  @impl true
  def handle_info({:checkupdate, time, loop}, state) do
    {order, files} = state

    {tasks, files} =
      files
      |> Enum.reduce({[], %{}}, fn x, acc ->
        {list, map} = acc
        {name, map2} = x
        %{:time => refresh, :left => left} = map2
        newtime = left - time

        cond do
          newtime <= 0 ->
            {[update_contents(name) | list], Map.put(map, name, Map.put(map2, :left, refresh))}

          true ->
            {list, Map.put(map, name, Map.put(map2, :left, newtime))}
        end
      end)

    files =
      tasks
      |> Enum.map(&Task.await/1)
      |> Enum.into(files, fn {file, content} ->
        %{^file => map} = files
        {file, Map.put(map, :content, content)}
      end)

    send_blocks(files, order)

    if loop do
      files
      |> get_minimum_time
      |> wait_for_time
    end

    {:noreply, {order, files}}
  end

  defp wait_for_time(time) do
    Process.send_after(self(), {:checkupdate, time, true}, time)
  end

  defp get_minimum_time(state) do
    state
    |> Enum.reduce(999_999, fn x, acc ->
      {_, %{:left => left}} = x
      min(left, acc)
    end)
  end

  defp send_blocks(files, order) do
    order
    |> Enum.reduce([], fn x, acc ->
      %{^x => %{:content => content}} = files

      case content do
        nil ->
          acc

        _ ->
          [Enum.join(content, ",") | acc]
      end
    end)
    |> Enum.join(",")
    |> (&IO.puts("[" <> &1 <> "]")).()

    files
  end
end
