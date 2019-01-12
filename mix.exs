defmodule Hive.MixProject do
  use Mix.Project

  def project do
    [
      app: :hive,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Hive.Application, []}
    ]
  end

  defp deps do
    [
      {:erlexec, "~>1.9.3"},
      {:elixir_uuid, "~> 1.2"},
      {:monero, path: "~/Code/exmnr/"},
      {:hackney, "~> 1.15.0"},
      {:jason, "~> 1.1.2"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]
end
