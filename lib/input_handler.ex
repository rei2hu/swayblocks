defmodule Input do
  def start_link(args) do
    args
    |> Enum.reduce(%{}, fn x, acc ->
      case x do
        {name, _, click_event} ->
          Map.put(acc, name, click_event)

        _ ->
          acc
      end
    end)
    |> (&Task.async(fn -> listen_for_input(&1) end)).()

    {:ok, self()}
  end

  defp listen_for_input(files) do
    IO.gets("")
    |> Poison.decode()
    |> handle_input(files)
    |> listen_for_input
  end

  defp handle_input(json, files) do
    case json do
      {:ok, map} ->
        case map["button"] do
          nil ->
            :ok = GenServer.call(:Updater, {:custom, map})

          _ ->
            :ok = GenServer.call(:Updater, {:click, map})
        end

      _ ->
        nil
    end

    files
  end
end
