defmodule SwayBlocks do
  use Application

  def start(_type, args) do
    [
      %{
        id: :Updater,
        start: {Updater, :start_link, [args]}
      },
      %{
        id: :Clicks,
        start: {Clicks, :start_link, [args]}
      }
    ]
    |> Supervisor.start_link(strategy: :one_for_one)
  end

  def prep_stop(_state) do
    IO.puts("bye!")
  end

  def update(pid) do
    GenServer.call(pid, :update)
  end
end
