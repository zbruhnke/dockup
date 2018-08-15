# https://hexdocs.pm/distillery/running-migrations.html
defmodule DockupUi.ReleaseTasks do

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def repos, do: Application.get_env(:dockup_ui, :ecto_repos, [])

  def migrate do
    IO.puts "Loading :dockup_ui.."
    # Load the code for dockup_ui, but don't start it
    :ok = Application.load(:dockup_ui)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # create databases
    create_databases()

    # Start the Repo(s) for dockup_ui
    IO.puts "Starting repos.."
    Enum.each(repos(), &(&1.start_link(pool_size: 1)))

    # run migrations
    migrate_repos()

    # Signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  def create_databases() do
    Enum.each(repos(), fn (repo) ->
      IO.inspect repo.config
      IO.inspect repo.__adapter__.storage_up(repo.config)
    end)
  end

  def migrate_repos, do: Enum.each(repos(), &run_migrations_for/1)

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
  end

  def migrations_path(repo), do: priv_path_for(repo, "migrations")

  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)
    repo_underscore = repo |> Module.split |> List.last |> Macro.underscore
    Path.join([priv_dir(app), repo_underscore, filename])
  end
end
