defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  alias DockupUi.{
    Deployment,
    Container,
    Blueprint
  }

  @moduledoc """
  Contains the information about a deployment.

  status - Refer to DockupUi.Callback for various states for this field.
  """

  @valid_statuses ~w(queued starting started hibernating hibernated waking_up deleting deleted failed)

  schema "deployments" do
    field :name, :string
    field :delete_at, :utc_datetime
    field :hibernate_at, :utc_datetime
    field :wake_up_at, :utc_datetime
    field :deployed_at, :utc_datetime
    field :status, :string

    belongs_to :blueprint, Blueprint
    has_many :containers, Container

    timestamps type: :utc_datetime
  end

  @doc false
def changeset(%Deployment{} = deployment, attrs) do
  deployment
  |> cast(attrs, [:name, :delete_at, :hibernate_at, :wake_up_at, :status, :deployed_at])
  |> cast_assoc(:containers)
  |> validate_required([:name, :status, :blueprint_id])
  |> validate_inclusion(:status, @valid_statuses)
end

  def transient_states do
    ~w(queued starting started hibernating waking_up deleting failed)
  end
end
