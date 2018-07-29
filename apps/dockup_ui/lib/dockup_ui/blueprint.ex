defmodule DockupUi.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Blueprint,
    ContainerSpec,
    Deployment
  }


  schema "blueprints" do
    field :name, :string

    has_many :container_specs, ContainerSpec
    has_many :deployments, Deployment

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(%Blueprint{} = blueprint, attrs) do
    blueprint
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
