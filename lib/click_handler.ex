defmodule Clicks do
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
    |> listen_for_clicks

    {:ok, self()}
  end

  defp listen_for_clicks(files) do
    IO.gets("")
    |> Poison.decode()
    |> handle_click(files)
    |> listen_for_clicks
  end

  defp handle_click(json, files) do
    case json do
      {:ok, map} ->
        :ok = GenServer.call(:Updater, {:click, map})

      _ ->
        nil
    end

    files
  end
end
