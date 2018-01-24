defmodule DockupUi.Plugs.GetCurrentUser do
  import Plug.Conn
  alias DockupUi.{
    Router.Helpers,
    Repo
  }

  def init(opts), do: opts

  def call(conn, _params) do
    case conn.assigns[:current_user] || get_session(conn, :current_user) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.redirect(to: Helpers.deployment_path(conn, :home))
        |> halt()
      current_user ->
        conn
        |> assign(:current_user, current_user)
        |> assign( :current_user_orgs, load_orgs(current_user))
    end
  end

  defp load_orgs(nil) do
    []
  end
  defp load_orgs(user) do
    user = Repo.preload(user, :organizations)
    user.organizations
  end
end
