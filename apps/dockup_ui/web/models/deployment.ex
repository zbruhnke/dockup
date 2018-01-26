defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  alias DockupUi.{
    Repository
  }

  @moduledoc """
  Contains the information about a deployment.

  status - Refer to DockupUi.Callback for various states for this field.
  """

  @derive {Poison.Encoder, only: [:id, :branch, :status, :updated_at, :inserted_at, :log_url, :urls, :repository_id]}

  schema "deployments" do
    field :branch, :string
    field :status, :string
    field :log_url, :string
    field :urls, {:array, :string}
    field :deleted_at, :utc_datetime

    belongs_to :repository, Repository

    timestamps type: :utc_datetime
  end

  @permitted_fields ~w(id branch status log_url urls inserted_at repository_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @permitted_fields)
  end

  @doc """
  This changeset is used when creating a deployment
  """
  def create_changeset(model, params) do
    required_fields = ~w(branch repository_id)a
    model
    |> cast(params, required_fields)
    |> validate_required(required_fields)
  end

  @doc """
  This changeset is used when deleting a deployment
  """
  def delete_changeset(model) do
    cast(model, %{deleted_at: DateTime.utc_now, log_url: nil, urls: nil}, [:deleted_at, :log_url, :urls])
  end
end
