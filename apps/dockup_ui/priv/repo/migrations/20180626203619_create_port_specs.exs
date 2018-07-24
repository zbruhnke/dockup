defmodule DockupUi.Repo.Migrations.CreatePortSpecs do
  use Ecto.Migration

  def change do
    create table(:port_specs) do
      add :protocol, :string
      add :port, :integer
      add :public, :boolean, default: false, null: false
      add :http_ready_response_code, :integer
      add :container_spec_id, references(:container_specs, on_delete: :nothing)
    end

    create index(:port_specs, [:container_spec_id])
  end
end
