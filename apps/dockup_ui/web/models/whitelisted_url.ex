defmodule DockupUi.WhitelistedUrl do
  use DockupUi.Web, :model

  alias DockupUi.{
    Organization
  }

  schema "whitelisted_urls" do
    field :git_url, :string

    belongs_to :organization, Organization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:git_url, :organization_id])
    |> validate_required([:git_url, :organization_id])
    |> unique_constraint(:git_url, name: :whitelisted_urls_organization_id_git_url_index, message: "URL already whitelisted.")
  end
end
