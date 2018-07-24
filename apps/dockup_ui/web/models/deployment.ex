defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  alias DockupUi.{
    Deployment,
    Container,
    Project
  }

  @moduledoc """
  Contains the information about a deployment.

  status - Refer to DockupUi.Callback for various states for this field.
  """

  schema "deployments" do
    field :name, :string
    field :delete_at, :utc_datetime
    field :hibernate_at, :utc_datetime
    field :wake_up_at, :utc_datetime
    field :status, :string

    belongs_to :project, Project
    has_many :containers, Container

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(%Deployment{} = deployment, attrs) do
    deployment
    |> cast(attrs, [:name, :delete_at, :hibernate_at, :wake_up_at, :status])
    |> validate_required([:name, :status])
  end
end
