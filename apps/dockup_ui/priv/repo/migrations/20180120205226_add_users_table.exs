defmodule DockupUi.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
  end
end
