defmodule DockupUi.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :name, :string
      add :image, :string
      add :tag, :string
      add :autodeploy, :boolean, default: false, null: false
      add :env, {:array, :map}
      add :command, :string
      add :args, {:array, :string}
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:containers, [:project_id])
  end
end
