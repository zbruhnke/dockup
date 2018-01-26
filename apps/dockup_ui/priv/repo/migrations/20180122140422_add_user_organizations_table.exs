defmodule DockupUi.Repo.Migrations.AddUserOrganizationsTable do
  use Ecto.Migration

  def change do
    create table(:user_organizations, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_organizations, [:user_id, :organization_id], unique: true)
  end
end
