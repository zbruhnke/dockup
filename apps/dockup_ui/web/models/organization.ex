defmodule DockupUi.Organization do
  use DockupUi.Web, :model

  alias DockupUi.{
    User,
    UserOrganization,
    Repository
  }

  schema "organizations" do
    field :name, :string

    has_many :repositories, Repository
    many_to_many :users, User, join_through: UserOrganization

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end

