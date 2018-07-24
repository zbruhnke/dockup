defmodule DockupUi.InitContainerSpec do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    ContainerSpec,
    InitContainerSpec
  }


  schema "init_container_specs" do
    field :order, :integer
    field :args, {:array, :string}, default: []
    field :command, :string
    field :env_vars, {:array, :map}, default: []
    field :image, :string
    field :tag, :string

    belongs_to :container_spec, ContainerSpec
  end

  @doc false
  def changeset(%InitContainerSpec{} = init_container, attrs) do
    init_container
    |> cast(attrs, [:order, :image, :tag, :command, :args, :env_vars])
    |> validate_required([:order, :image, :tag, :container_spec_id])
  end
end
