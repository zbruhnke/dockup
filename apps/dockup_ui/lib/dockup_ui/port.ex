defmodule DockupUi.Port do
  use Ecto.Schema
  import Ecto.Changeset

  alias DockupUi.{
    Port,
    Container,
    PortSpec
  }


  schema "ports" do
    field :endpoint, :string
    field :ready, :boolean

    belongs_to :container, Container
    belongs_to :port_spec, PortSpec
  end

  @doc false
  def changeset(%Port{} = port, attrs) do
    port
    |> cast(attrs, [:endpoint, :ready])
    |> validate_required([:endpoint, :container_id, :port_spec_id])
    |> unique_constraint(:endpoint)
  end
end
