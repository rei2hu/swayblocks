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

    pid1 = spawn_link(fn -> EventLoop.start(args) end)
    spawn_link(fn -> InputHandler.listen(pid1) end)
    {:ok, self()}
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
