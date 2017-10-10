defmodule DockupUi.Mixfile do
  use Mix.Project

  def project do
    [app: :dockup_ui,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {DockupUi, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :quantum, :httpotion]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "web", "test/support/factory.ex"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:postgrex, "~> 0.13.3"},
     {:phoenix_ecto, "~> 3.2"},
     {:phoenix_html, "~> 2.10"},
     {:phoenix_live_reload, "~> 1.1", only: :dev},
     {:gettext, "~> 0.13"},
     {:cowboy, "~> 1.1"},
     {:httpotion, "~> 3.0.0"},
     {:poison, "~> 3.1.0"},
     {:quantum, "~> 2.0.2"},
     {:flow, "~> 0.12.0"},
     {:dockup, in_umbrella: true, only: [:prod]},
     {:fake_dockup, in_umbrella: true, only: [:dev, :test]}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
