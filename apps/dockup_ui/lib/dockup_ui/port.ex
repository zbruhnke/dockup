defmodule DockupUi.Port do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Port,
    Container
  }


  schema "ports" do
    field :custom_subdomain, :string
    field :expose, :boolean, default: false
    field :port, :integer
    field :protocol, :string

    belongs_to :container, Container

    timestamps()
  end

  @doc false
  def changeset(%Port{} = port, attrs) do
    port
    |> cast(attrs, [:protocol, :port, :expose, :custom_subdomain])
    |> validate_required([:protocol, :port, :expose, :custom_subdomain])
    |> unique_constraint(:custom_subdomain)
  end
end
