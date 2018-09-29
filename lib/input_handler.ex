defmodule Input do
  @moduledoc """
  This handles things from stdin
  """

  @doc """
  Starts the endless listening loop

  Returns `{:ok, pid}`
  """
  def start_link(_) do
    Task.async(fn -> listen_for_input() end)

    {:ok, self()}
  end

  defp listen_for_input() do
    IO.gets("")
    |> Poison.decode()
    |> handle_input

    listen_for_input()
  end

  defp handle_input(json) do
    case json do
      {:ok, %{"name" => _} = map} ->
        cond do
          map["button"] != nil ->
            :ok = GenServer.call(:Updater, {:click, map})

          map["action"] != nil ->
            :ok = GenServer.call(:Updater, {:custom, map})

          true ->
            nil
        end

      _ ->
        nil
    end
  end
end
