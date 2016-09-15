defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  @moduledoc """
  Contains the information about a deployment.

  status - Refer to DockupUi.Callback for various states for this field.
  """

  @derive {Poison.Encoder, only: [:id, :git_url, :branch, :callback_url, :status]}

  schema "deployments" do
    field :git_url, :string
    field :branch, :string
    field :callback_url, :string
    field :status, :string
    field :log_url, :string
    field :service_urls, :map

    timestamps
  end

  @required_fields ~w(git_url branch)
  @optional_fields ~w(callback_url status log_url service_urls)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  This changeset is used when creating a deployment
  """
  def create_changeset(model, params \\ :empty) do
    required_fields = ~w(git_url branch)
    optional_fields = ~w(callback_url)
    model |> cast(params, required_fields, optional_fields)
  end
end
