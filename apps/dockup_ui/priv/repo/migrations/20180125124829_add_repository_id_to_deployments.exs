defmodule DockupUi.Repo.Migrations.AddRepositoryIdToDeployments do
  use Ecto.Migration

  def change do
    alter table(:deployments) do
      add :repository_id, references(:repositories)
      remove :git_url
      remove :callback_url
    end

    create index(:deployments, [:repository_id])
  end
end
