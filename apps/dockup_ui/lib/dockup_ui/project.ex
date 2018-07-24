defmodule DockupUi.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Project,
    ContainerSpec,
    Deployment
  }


  schema "projects" do
    field :name, :string

    has_many :container_specs, ContainerSpec
    has_many :deployments, Deployment

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(%Project{} = project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
