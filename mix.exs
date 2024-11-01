defmodule FalconBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :falconbot,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {FalconBot.Application, []}
    ]
  end

  defp deps do
    [
      {:nostrum, "~> 0.10"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 2.0"}
    ]
  end
end
