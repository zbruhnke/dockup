defmodule DockupUi.Repo.Migrations.CreateBlueprint do
  use Ecto.Migration

  def change do
    create table(:blueprints) do
      add :name, :string

      timestamps()
    end

  end
end
