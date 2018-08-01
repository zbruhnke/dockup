defmodule DockupUi.Subdomain do
  use Ecto.Schema
  import Ecto.Changeset

  alias DockupUi.{
    Port,
    Subdomain
  }


  schema "subdomains" do
    field :subdomain, :string

    belongs_to :port, Port
  end

  @doc false
  def changeset(%Subdomain{} = subdomain, attrs) do
    subdomain
    |> cast(attrs, [:subdomain, :port_id])
    |> validate_required([:subdomain])
    |> unique_constraint(:subdomain)
  end
end
