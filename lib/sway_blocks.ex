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

    {:ok, _} = Updater.start_link(args)
    {:ok, _} = Input.start_link()
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
