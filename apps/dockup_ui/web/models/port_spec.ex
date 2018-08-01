defmodule DockupUi.PortSpec do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    ContainerSpec,
    PortSpec,
    Ingress
  }


  schema "port_specs" do
    field :protocol, :string, default: "TCP"
    field :port, :integer
    field :public, :boolean, default: false
    field :http_ready_response_code, :integer

    belongs_to :container_spec, ContainerSpec
    has_one :ingress, Ingress
  end

  @doc false
  def changeset(%PortSpec{} = port_spec, attrs) do
    port_spec
    |> cast(attrs, [:protocol, :port, :public, :http_ready_response_code])
    |> validate_required([:port, :public])
  end
end
