defmodule DockupUi.Plugs.GetCurrentUser do
  import Plug.Conn
  alias DockupUi.Router.Helpers

  def init(opts), do: opts

  def call(conn, _params) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.put_flash(:error, "Please log in or register to continue.")
        |> Phoenix.Controller.redirect(to: Helpers.deployment_path(conn, :home))
        |> halt()
      _ ->
        conn
    end
  end
end
