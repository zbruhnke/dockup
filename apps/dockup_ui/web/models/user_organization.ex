defmodule DockupUi.UserOrganization do
  use Ecto.Schema

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
  end
end
