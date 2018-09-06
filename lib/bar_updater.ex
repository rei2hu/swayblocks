defmodule Updater do
  def start_link(args) do
    args
    |> Updater.prepare_processes()
    |> Updater.start()

    {:ok, self()}
  end

  def prepare_processes(files) do
    IO.puts("{\"version\":1}")
    IO.puts("[")

    files
    |> Enum.map(fn x ->
      {string, _} = x

      %{
        id: string,
        start: {BlockWatcher, :start_link, [string]}
      }
    end)
    |> Supervisor.start_link(strategy: :one_for_one)

    files
  end

  defp wait_and_subtract_time({info, time}) do
    :timer.sleep(time)

    info
    |> Enum.map(fn x -> Map.put(x, :left, x[:left] - time) end)
    |> execute_scripts
  end

  def start(scripts) do
    scripts
    |> Enum.map_reduce(99999, fn x, acc ->
      {name, time} = x

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
    |> wait_and_subtract_time
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
    |> get_minimum_time
  end

  defp send_blocks(blocks, info) do
    IO.puts("[" <> blocks <> "]")
    info
  end
end
