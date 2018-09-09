defmodule SwayBlocks do
  use Application

  def start(_type, _args) do
    args = Application.get_env(:SwayBlocks, :args, [])

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

  def main(_) do
  end
end
