defmodule SwayBlocks do
  use Application

  def start(_type, _args) do
    {args, _} = Code.eval_file(Path.expand("~/.config/swayblocks/config.exs"))

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
    :timer.sleep(:infinity)
  end
end
