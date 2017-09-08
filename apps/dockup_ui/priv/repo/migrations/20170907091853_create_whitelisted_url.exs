defmodule DockupUi.Repo.Migrations.CreateWhitelistedUrl do
  use Ecto.Migration

  def change do
    create table(:whitelisted_urls) do
      add :git_url, :string

      timestamps()
    end

    create index(:whitelisted_urls, [:git_url], unique: true)
  end
end
