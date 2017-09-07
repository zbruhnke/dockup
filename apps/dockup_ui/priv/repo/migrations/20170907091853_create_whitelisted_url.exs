defmodule DockupUi.Repo.Migrations.CreateWhitelistedUrl do
  use Ecto.Migration

  def change do
    create table(:whitelisted_urls) do
      add :git_url, :string

      timestamps()
    end
  end
end
