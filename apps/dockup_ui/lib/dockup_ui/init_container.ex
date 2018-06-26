defmodule DockupUi.InitContainer do
  use Ecto.Schema
  import Ecto.Changeset
  alias DockupUi.{
    InitContainer,
    Container
  }


  schema "init_containers" do
    field :args, {:array, :string}
    field :command, :string
    field :env, {:array, :map}
    field :image, :string
    field :name, :string
    field :tag, :string

    belongs_to :container, Container

    timestamps()
  end

  @doc false
  def changeset(%InitContainer{} = init_container, attrs) do
    init_container
    |> cast(attrs, [:name, :image, :tag, :command, :args, :env])
    |> validate_required([:name, :image, :tag, :command, :args, :env])
  end
end
