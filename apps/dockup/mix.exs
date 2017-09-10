defmodule Dockup.Mixfile do
  use Mix.Project

  def project do
    [app: :dockup,
     version: "0.0.1",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      applications: [:logger, :poison, :httpotion],
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1.0"},
      {:httpotion, "~> 3.0.3"},
      {:dockup_spec, in_umbrella: true}
    ]
  end
end
