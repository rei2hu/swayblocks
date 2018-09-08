defmodule SwayBlocks.MixProject do
  use Mix.Project

  def project do
    [
      app: :swayblocks,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod:
        {SwayBlocks,
         [
           {:"scripts/date", 1000},
           {:"scripts/battery", 30000},
           {:"scripts/brightness", 10000},
           {:"scripts/wifi", 5000},
           {:"scripts/volume", 5000, :"scripts/click/volctrl"},
           {:"scripts/cmus", 5000, :"scripts/click/pause"}
         ]},
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
