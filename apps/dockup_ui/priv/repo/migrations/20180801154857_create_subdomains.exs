defmodule DockupUi.Repo.Migrations.CreateSubdomains do
  use Ecto.Migration

  def change do
    create table(:subdomains) do
      add :subdomain, :string
      add :ingress_id, references(:ingresses, on_delete: :nothing)
    end

    create index(:subdomains, [:ingress_id])
    create index(:subdomains, [:subdomain], unique: true)
  end
end
