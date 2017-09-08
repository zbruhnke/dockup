defmodule DockupUi.Deployment do
  use DockupUi.Web, :model

  alias DockupUi.{
    WhitelistedUrl,
    Repo
  }

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
    field :urls, {:array, :string}

    timestamps()
  end

  @permitted_fields ~w(id git_url branch callback_url status log_url urls inserted_at)

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
    required_fields = ~w(git_url branch)a
    optional_fields = ~w(callback_url)a
    model
    |> cast(params, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> validate_whitelisted_git_url()
  end

  # Check if git URL is whitelisted
  defp validate_whitelisted_git_url(changeset) do
    if git_url = get_field(changeset, :git_url) do
      if whitelisted?(git_url) do
        changeset
      else
        add_error(changeset, :git_url, "is not whitelisted for deployment")
      end
    else
      changeset
    end
  end

  defp whitelisted?(url) do
    not is_nil(Repo.get_by(WhitelistedUrl, git_url: url))
  end
end
