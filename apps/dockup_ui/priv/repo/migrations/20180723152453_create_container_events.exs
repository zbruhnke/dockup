defmodule DockupUi.Repo.Migrations.CreateContainerEvents do
  use Ecto.Migration

  def change do
    create table(:container_events) do
      add :event, :string
      add :timestamp, :utc_datetime
      add :container_id, references(:containers, on_delete: :nothing)
    end

    create index(:container_events, [:container_id])
  end
end
