defmodule DigiBattleCrawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :digi_battle_crawler,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crawly, "~> 0.16.0"},
      {:floki, "~> 0.33.0"}
    ]
  end
end
