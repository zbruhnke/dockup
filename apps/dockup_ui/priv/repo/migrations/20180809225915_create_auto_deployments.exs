defmodule DockupUi.Repo.Migrations.CreateAutoDeployments do
  use Ecto.Migration

  def change do
    create table(:auto_deployments) do
      add :tag, :string, default: "*"
      add :container_spec_id, references(:container_specs, on_delete: :delete_all)

      timestamps()
    end

    create index(:auto_deployments, [:container_spec_id, :tag], unique: true)
  end
end
