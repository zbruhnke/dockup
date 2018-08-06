defmodule DockupUi.Container do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Container,
    ContainerSpec,
    Deployment,
    Ingress
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
    has_many :ingresses, Ingress
  end

  @doc false
  def changeset(%Container{} = container, attrs) do
    container
    |> cast(attrs, [:autodeploy, :tag, :container_spec_id, :handle, :status])
    |> cast_assoc(:ingresses)
    |> validate_required([:autodeploy, :status, :tag, :container_spec_id])
  end

  def update_tag_changeset(id, handle) do
    %Container{id: id}
    |> cast(%{handle: handle}, [:handle])
  end

  @doc false
  def status_update_changeset(%Container{} = container, status) do
    container
    |> cast(%{status: status, status_synced_at: DateTime.utc_now()}, [:status, :status_synced_at])
    |> validate_required([:status, :status_synced_at])
    |> validate_inclusion(:status, @valid_statuses)
  end

  def transient_states do
    ~w(pending running failed)
  end
end
