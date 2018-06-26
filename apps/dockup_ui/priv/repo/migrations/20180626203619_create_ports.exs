defmodule DockupUi.Repo.Migrations.CreatePorts do
  use Ecto.Migration

  def change do
    create table(:ports) do
      add :protocol, :string
      add :port, :integer
      add :expose, :boolean, default: false, null: false
      add :custom_subdomain, :string
      add :container_id, references(:containers, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:ports, [:custom_subdomain])
    create index(:ports, [:container_id])
  end
end
