defmodule DockupUi.User do
  use DockupUi.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name])
    |> validate_required([:email, :name])
  end
end
