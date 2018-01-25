defmodule DockupUi.Repo.Migrations.RenameWhitelistedUrlsToRepositories do
  use Ecto.Migration

  def change do
    drop index(:whitelisted_urls, [:git_url])

    alter table(:whitelisted_urls) do
      add :organization_id, references(:organizations)
    end

    rename table(:whitelisted_urls), to: table(:repositories)
    create index(:repositories, [:organization_id, :git_url], unique: true)
  end
end
