defmodule DockupUi.Subdomain do
  use Ecto.Schema
  import Ecto.Changeset

  alias DockupUi.{
    Ingress,
    Subdomain
  }


  schema "subdomains" do
    field :subdomain, :string

    belongs_to :ingress, Ingress
  end

  @doc false
  def changeset(%Subdomain{} = subdomain, attrs) do
    subdomain
    |> cast(attrs, [:subdomain, :ingress_id])
    |> validate_required([:subdomain])
    |> unique_constraint(:subdomain)
  end
end
