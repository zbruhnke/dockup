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
      applications: [:logger, :kazan],
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  defp deps do
    [
      {:kazan, github: "emilsoman/kazan"}
    ]
  end
end
