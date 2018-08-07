defmodule DockupUi.Plugs.GetCurrentUser do
  import Plug.Conn
  alias DockupUi.Router.Helpers

  def init(opts), do: opts

  def call(conn, _params) do
    case load_current_user(conn) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.redirect(to: Helpers.deployment_path(conn, :home))
        |> halt()
      current_user ->
        conn
        |> assign(:user_token, Phoenix.Token.sign(conn, "user socket", current_user))
    end
  end

  defp load_current_user(conn) do
    conn.assigns[:current_user] || get_session(conn, :current_user)
  end
end
