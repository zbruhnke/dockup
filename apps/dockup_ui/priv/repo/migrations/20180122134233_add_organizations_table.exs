defmodule DockupUi.Repo.Migrations.AddOrganizationsTable do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string

      timestamps()
    end

    create unique_index(:organizations, [:name])
  end
end
