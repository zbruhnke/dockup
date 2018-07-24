defmodule DockupUi.ContainerEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias DockupUi.{
    Container,
    ContainerEvent
  }


  schema "ports" do
    field :event, :string
    field :timestamp, :utc_datetime

    belongs_to :container, Container
  end

  @doc false
  def changeset(%ContainerEvent{} = container_event, event) do
    container_event
    |> cast(%{event: event, timestamp: DateTime.utc_now()}, [:event, :timestamp])
    |> validate_required([:event, :timestamp, :container_id])
  end
end
