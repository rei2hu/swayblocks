defmodule SwayBlocks do
  use Application

  @moduledoc """
  The main module
  """

  @doc """
  Starts the supervisor, updater, and input handling processes

  Returns `{:ok, pid}`
  """
  def start(_type, _args) do
    {args, _} = Code.eval_file(Path.expand("~/.config/swayblocks/config.exs"))

    [
      %{
        id: :Updater,
        start: {Updater, :start_link, [args]}
      },
      %{
        id: :Input,
        start: {Input, :start_link, [args]}
      }
    ]
    |> Supervisor.start_link(strategy: :one_for_one)
  end

  @doc """
  The main method if build using escript

  Returns `nil`
  """
  def main(_) do
    :timer.sleep(:infinity)
    nil
  end
end
