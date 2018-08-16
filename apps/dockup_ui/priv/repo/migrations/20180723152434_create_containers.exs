defmodule DockupUi.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :handle, :string
      add :tag, :string
      add :status, :string
      add :status_reason, :string
      add :status_synced_at, :utc_datetime
      add :deployment_id, references(:deployments, on_delete: :nothing)
      add :container_spec_id, references(:container_specs, on_delete: :nothing)
    end

    create index(:containers, [:deployment_id])
    create index(:containers, [:container_spec_id])
  end
end
