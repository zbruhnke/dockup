defmodule DockupUi.Plugs.AuthorizeUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _params) do
    if conn.params["organization_id"] && authorized?(conn) do
      conn
    else
      conn
      |> send_resp(:forbidden, "Forbidden.")
      |> halt()
    end
  end

  defp authorized?(conn) do
    Enum.any? conn.assigns[:current_user_orgs], fn org ->
      org.id == String.to_integer(conn.params["organization_id"])
    end
  end
end
