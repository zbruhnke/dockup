defmodule DockupUi.UserOrganization do
  use Ecto.Schema

  alias DockupUi.{
    User,
    Organization
  }

  @primary_key false
  schema "user_organizations" do
    belongs_to :user, User
    belongs_to :organization, Organization

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:user_id, :organization_id])
    |> Ecto.Changeset.validate_required([:user_id, :organization_id])
    |> Ecto.Changeset.unique_constraint(:email, name: :user_organizations_user_id_organization_id_index, message: "User already part of organization")
  end
end
