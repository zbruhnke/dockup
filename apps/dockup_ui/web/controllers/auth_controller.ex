defmodule DockupUi.AuthController do
  alias DockupUi.UserFromAuth

  use DockupUi.Web, :controller
  plug Ueberauth
  plug :put_layout, "home.html"

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: unauthenticated_path(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: unauthenticated_path(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: deployment_path(conn, :new))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: unauthenticated_path(conn))
    end
  end

  defp unauthenticated_path(conn) do
    deployment_path(conn, :home)
  end
end
