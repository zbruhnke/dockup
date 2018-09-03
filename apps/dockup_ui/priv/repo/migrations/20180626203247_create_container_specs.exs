defmodule DockupUi.Repo.Migrations.CreateContainerSpecs do
  use Ecto.Migration

  def change do
    create table(:container_specs) do
      add :name, :string
      add :image, :string
      add :default_tag, :string
      add :env_vars, {:map, :string}
      add :command, :string
      add :args, {:array, :string}
      add :blueprint_id, references(:blueprints, on_delete: :nothing)
      add :requests_cpu, :string
      add :limits_cpu, :string
      add :requests_mem, :string
      add :limits_mem, :string
    end

    create index(:container_specs, [:blueprint_id])
  end
end
