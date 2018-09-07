defmodule Updater do
  def start_link(args) do
    files =
      args
      |> Updater.prepare_processes()

    Task.async(fn -> Updater.start(files) end)

    {:ok, self()}
  end

  def prepare_processes(files) do
    IO.puts("{\"version\":1,\"click_events\":true}")
    IO.puts("[")

    files
    |> Enum.map(fn x ->
      name = elem(x, 0)

      %{
        id: name,
        start: {BlockWatcher, :start_link, [name]}
      }
    end)
    |> Supervisor.start_link(strategy: :one_for_one)

    files
  end

  defp wait_and_subtract_time({info, time}) do
    Process.send_after(self(), :goupdate, time)

    receive do
      :goupdate ->
        info
        |> Enum.map(fn x -> Map.put(x, :left, x[:left] - time) end)
        |> execute_scripts
        |> get_minimum_time
        |> wait_and_subtract_time

      _ ->
        "monkaGIGA"
    end
  end

  def start(scripts) do
    scripts
    |> Enum.map_reduce(99999, fn x, acc ->
      name = elem(x, 0)
      time = elem(x, 1)

      {
        %{:name => name, :time => time, :left => time},
        min(time, acc)
      }
    end)
    |> wait_and_subtract_time
  end

  defp get_minimum_time(info) do
    info
    |> Enum.map_reduce(99999, fn x, acc ->
      %{:time => time, :left => left} = x
      left = if left <= 0, do: time, else: left

      {
        Map.put(x, :left, left),
        min(left, acc)
      }
    end)
  end

  defp execute_scripts(info) do
    info
    |> Enum.map_join(",", fn x ->
      %{:name => name, :left => left} = x

      case left do
        0 ->
          %{:blocks => blocks} = GenServer.call(name, :update)
          Enum.join(blocks, ",")

        _ ->
          %{:blocks => blocks} = GenServer.call(name, :get)
          Enum.join(blocks, ",")
      end
    end)
    |> send_blocks(info)
  end

  defp send_blocks(blocks, info) do
    IO.puts("[" <> blocks <> "]")
    info
  end
end
