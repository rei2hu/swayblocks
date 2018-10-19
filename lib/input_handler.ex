defmodule InputHandler do
  @moduledoc """
  This handles things from stdin
  """

  @doc """
  Starts the endless listening loop
  """
  def listen(event_loop_pid) do
    IO.gets("")
    |> String.replace_prefix(",", "")
    |> String.replace_suffix(",\n", "")
    |> Poison.decode()
    |> handle_input(event_loop_pid)

    listen(event_loop_pid)
  end

  defp handle_input(json, pid) do
    # json is already decoded,
    # send this to the event loop
    case json do
      {:ok, %{"name" => _} = map} ->
        cond do
          # send a :click event with the map variable
          map["button"] != nil ->
            send(pid, {:click, map})

          # send a :custom event with the map variable
          map["action"] != nil ->
            send(pid, {:custom, map})

          true ->
            nil
        end

      _ ->
        nil
    end
  end
end
