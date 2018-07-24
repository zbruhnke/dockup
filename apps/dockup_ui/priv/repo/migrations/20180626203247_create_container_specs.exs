defmodule DockupUi.Repo.Migrations.CreateContainerSpecs do
  use Ecto.Migration

  def change do
    create table(:container_specs) do
      add :name, :string
      add :image, :string
      add :default_tag, :string
      add :env_vars, {:array, :map}
      add :command, :string
      add :args, {:array, :string}
      add :project_id, references(:projects, on_delete: :nothing)
    end

    create index(:container_specs, [:project_id])
  end
end
