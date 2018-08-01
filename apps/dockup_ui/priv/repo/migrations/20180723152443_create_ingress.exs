defmodule DockupUi.Repo.Migrations.CreateIngress do
  use Ecto.Migration

  def change do
    create table(:ingresses) do
      add :endpoint, :string
      add :ready, :boolean
      add :container_id, references(:containers, on_delete: :nothing)
      add :port_spec_id, references(:port_specs, on_delete: :nothing)
    end

    create index(:ingresses, [:container_id])
    create index(:ingresses, [:port_spec_id])
    create index(:ingresses, [:endpoint], unique: true)
  end
end
