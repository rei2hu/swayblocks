defmodule SwayBlocks.MixProject do
  use Mix.Project

  def project do
    [
      app: :swayblocks,
      version: "0.1.0",
      elixir: "~> 1.7",
      escript: escript(),
      deps: deps()
    ]
  end

  def escript do
    [main_module: SwayBlocks]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SwayBlocks, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"}
    ]
  end
end
