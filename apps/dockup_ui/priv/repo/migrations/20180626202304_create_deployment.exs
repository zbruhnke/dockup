defmodule DockupUi.Repo.Migrations.CreateDeployment do
  use Ecto.Migration

  def change do
    create table(:deployments) do
      add :name, :string
      add :delete_at, :utc_datetime
      add :hibernate_at, :utc_datetime
      add :wake_up_at, :utc_datetime
      add :status, :string
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:deployments, [:project_id])
    create index(:deployments, [:delete_at])
    create index(:deployments, [:hibernate_at])
    create index(:deployments, [:wake_up_at])
    create index(:deployments, [:status])
  end
end
