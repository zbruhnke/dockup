defmodule DockupUi.Repo.Migrations.AddOrganizationIdToDeployments do
  use Ecto.Migration

  def change do
    alter table(:whitelisted_urls) do
      add :organization_id, references(:organizations)
    end

    drop index(:whitelisted_urls, [:git_url])
    create index(:whitelisted_urls, [:organization_id, :git_url], unique: true)
  end
end
