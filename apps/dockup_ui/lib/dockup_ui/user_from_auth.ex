defmodule DockupUi.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth
  alias DockupUi.{
    User,
    Repo
  }

  def find_or_create(%Auth{info: %{email: email, name: name, urls: %{website: domain}}}) do
    google_domain = Application.get_env(:dockup_ui, :google_domain)
    if is_nil(google_domain) || domain == google_domain do
      login_user(email, name)
    else
      {:error, "User not allowed to log in."}
    end
  end

  defp login_user(email, name) do
    case Repo.get_by(User, email: email) do
      nil ->
        create_user(%{email: email, name: name})
      user ->
        update_name(user, name)
    end
  end

  defp create_user(params) do
    changeset = User.changeset(%User{}, params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, user}
      {:error, _} ->
        error = "User cannot be created with params: #{inspect params}"
        Logger.error(error)
        {:error, error}
    end
  end

  defp update_name(user, name) do
    user
    |> User.changeset(%{name: name})
    |> Repo.update()
  end
end
