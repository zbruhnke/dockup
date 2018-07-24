defmodule DockupUi.ContainerSpec do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    PortSpec,
    InitContainerSpec,
    Project,
    ContainerSpec,
  }


  schema "container_specs" do
    field :name, :string
    field :image, :string
    field :default_tag, :string
    field :command, :string
    field :args, {:array, :string}, default: []
    field :env_vars, {:array, :map}, default: []

    belongs_to :project, Project
    has_many :port_specs, PortSpec
    has_many :init_container_specs, InitContainerSpec
  end

  @doc false
  def changeset(%ContainerSpec{} = container_spec, attrs) do
    container_spec
    |> cast(attrs, [:name, :image, :default_tag, :command, :args, :env_vars])
    |> validate_required([:name, :image, :default_tag, :project_id])
  end
end
