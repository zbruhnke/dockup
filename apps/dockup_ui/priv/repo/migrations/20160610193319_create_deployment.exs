defmodule DockupUi.Repo.Migrations.CreateDeployment do
  use Ecto.Migration

  def change do
    create table(:deployments) do
      add :git_url, :string
      add :branch, :string
      add :callback_url, :string
      add :status, :string
      add :log_url, :string
      add :urls, {:array, :string}
      add :deleted_at, :utc_datetime

      timestamps()
    end

  end
end
