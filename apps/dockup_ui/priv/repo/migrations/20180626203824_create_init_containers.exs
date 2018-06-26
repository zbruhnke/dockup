defmodule DockupUi.Repo.Migrations.CreateInitContainers do
  use Ecto.Migration

  def change do
    create table(:init_containers) do
      add :name, :string
      add :image, :string
      add :tag, :string
      add :command, :string
      add :args, {:array, :string}
      add :env, {:array, :map}
      add :container_id, references(:containers, on_delete: :nothing)

      timestamps()
    end

    create index(:init_containers, [:container_id])
  end
end
