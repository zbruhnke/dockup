defmodule DockupUi.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.Project


  schema "projects" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Project{} = project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
