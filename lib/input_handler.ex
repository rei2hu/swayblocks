defmodule Input do
  @moduledoc """
  This handles things from stdin
  """

  @doc """
  Starts the endless listening loop

  Returns `{:ok, pid}`
  """
  def start_link(_) do
    Task.async(fn -> listen_for_input(nil) end)

    {:ok, self()}
  end

  defp listen_for_input(_) do
    IO.gets("")
    |> Poison.decode()
    |> handle_input
    |> listen_for_input
  end

  defp handle_input(json) do
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
  end
end
