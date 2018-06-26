defmodule DockupUi.Container do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    Container,
    Port,
    InitContainer,
    Project
  }


  schema "containers" do
    field :args, {:array, :string}
    field :autodeploy, :boolean, default: false
    field :command, :string
    field :env, {:array, :map}
    field :image, :string
    field :name, :string
    field :tag, :string

    belongs_to :project, Project
    has_many :ports, Port
    has_many :init_containers, InitContainer

    timestamps()
  end

  @doc false
  def changeset(%Container{} = container, attrs) do
    container
    |> cast(attrs, [:name, :image, :tag, :autodeploy, :env, :command, :args])
    |> validate_required([:name, :image, :tag, :autodeploy, :env, :command, :args])
  end
end
