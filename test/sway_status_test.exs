defmodule Sway.StatusTest do
  use ExUnit.Case
  doctest Sway.Status

  test "greets the world" do
    assert Sway.Status.hello() == :world
  end
end
