defmodule DockupUi.Container do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Container,
    ContainerSpec,
    Deployment,
    Port
  }

  @valid_statuses ~w(unknown pending running failed)

  schema "containers" do
    field :handle, :string
    field :autodeploy, :boolean, default: false
    field :status_synced_at, :utc_datetime
    field :status, :string
    field :tag, :string

    belongs_to :deployment, Deployment
    belongs_to :container_spec, ContainerSpec
    has_many :ports, Port
  end

  @doc false
  def create_changeset(attrs) do
    %Container{status: "unknown"}
    |> cast(attrs, [:autodeploy, :tag, :container_spec_id])
    |> cast_assoc(:ports)
    |> validate_required([:autodeploy, :status, :tag, :container_spec_id, :blueprint_id])
  end

  @doc false
  def status_update_changeset(%Container{} = container, status) do
    container
    |> cast(%{status: status, status_synced_at: DateTime.utc_now()}, [:status, :status_synced_at])
    |> validate_required([:status, :status_synced_at])
    |> validate_inclusion(:status, @valid_statuses)
  end
end
