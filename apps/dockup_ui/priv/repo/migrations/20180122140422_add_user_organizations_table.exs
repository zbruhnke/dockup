defmodule DockupUi.Repo.Migrations.AddUserOrganizationsTable do
  use Ecto.Migration

  def change do
    create table(:user_organizations, primary_key: false) do
      add :user_id, references(:users)
      add :organization_id, references(:organizations)

      timestamps()
    end

    create index(:user_organizations, [:user_id, :organization_id], unique: true)
  end
end
