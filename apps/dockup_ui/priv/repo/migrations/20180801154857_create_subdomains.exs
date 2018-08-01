defmodule DockupUi.Repo.Migrations.CreateSubdomains do
  use Ecto.Migration

  def change do
    create table(:subdomains) do
      add :subdomain, :string
      add :port_id, references(:ports, on_delete: :nothing)
    end

    create index(:subdomains, [:port_id])
    create index(:subdomains, [:subdomain], unique: true)
  end
end
