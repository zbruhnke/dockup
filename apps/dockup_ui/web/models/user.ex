defmodule DockupUi.User do
  use DockupUi.Web, :model

  alias DockupUi.{
    Organization,
    UserOrganization
  }

  schema "users" do
    field :email, :string
    field :name, :string

    many_to_many :organizations, Organization, join_through: UserOrganization

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name])
    |> validate_required([:email])
  end
end
