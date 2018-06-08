# https://hexdocs.pm/distillery/running-migrations.html
defmodule DockupUi.ReleaseTasks do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :dockup_ui
  ]

  def migrate do
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    create_database_repo()
    run_migrations()
  end

  defp create_database_repo() do
    config = [database: "dockup_ui_prod"]

    IO.puts("Creating repository")
    case Ecto.Adapters.Postgres.storage_up(config) do
      {:ok, _} -> IO.puts("Created successfully")
      {:error, :already_up} -> IO.puts("Already created")
      {:error, error} -> raise "errored: #{error}"
    end
  end

  defp run_migrations() do
    IO.puts("Running migrations for the app")
    repo = Application.get_env(:dockup_ui, :ecto_repos, []) |> List.first
    path = Path.join([:code.priv_dir(:dockup_ui), "repo", "migrations"])
    Ecto.Migrator.run(repo, path, :up, all: true)
  end
end
