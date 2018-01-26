defmodule DockupUi.Repository do
  use DockupUi.Web, :model

  alias DockupUi.{
    Organization,
    Deployment
  }

  schema "repositories" do
    field :git_url, :string

    belongs_to :organization, Organization
    has_many :deployments, Deployment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:git_url, :organization_id])
    |> validate_required([:git_url, :organization_id])
    |> unique_constraint(:git_url, name: :repositories_organization_id_git_url_index, message: "Repository already added.")
  end
end
