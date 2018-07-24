defmodule DockupUi.Repo.Migrations.CreatePorts do
  use Ecto.Migration

  def change do
    create table(:ports) do
      add :endpoint, :string
      add :ready, :boolean
      add :container_id, references(:containers, on_delete: :nothing)
      add :port_spec_id, references(:port_specs, on_delete: :nothing)
    end

    create index(:ports, [:container_id])
    create index(:ports, [:port_spec_id])
    create index(:ports, [:endpoint], unique: true)
  end
end
