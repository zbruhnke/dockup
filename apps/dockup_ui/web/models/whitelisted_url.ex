defmodule DockupUi.WhitelistedUrl do
  use DockupUi.Web, :model

  schema "whitelisted_urls" do
    field :git_url, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:git_url])
    |> validate_required([:git_url])
  end
end
