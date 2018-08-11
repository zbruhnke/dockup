defmodule DockupUi.AutoDeployment do
  use DockupUi.Web, :model

  alias DockupUi.{
    AutoDeployment,
    ContainerSpec
  }

  schema "auto_deployments" do
    field :tag, :string, default: "*"
    belongs_to :container_spec, ContainerSpec

    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(%AutoDeployment{} = auto_deployment, attrs) do
    auto_deployment
    |> cast(attrs, [:tag])
    |> validate_required([:tag, :container_spec_id])
  end
end
