defmodule DockupUi.Repo.Migrations.CreateInitContainerSpecs do
  use Ecto.Migration

  def change do
    create table(:init_container_specs) do
      add :order, :integer
      add :image, :string
      add :tag, :string
      add :command, :string
      add :args, {:array, :string}
      add :env_vars, {:map, :string}
      add :container_spec_id, references(:container_specs, on_delete: :nothing)
    end

    create index(:init_container_specs, [:container_spec_id])
  end
end
