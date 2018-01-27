defmodule DockupUi.ConfigController do
  use DockupUi.Web, :controller
  plug DockupUi.Plugs.AuthorizeUser

  def index(conn, _params) do
    organization = find_org(conn) |> Repo.preload([:users, :repositories])
    render(conn, "index.html", organization: organization)
  end

  defp find_org(conn) do
    Enum.find conn.assigns[:current_user_orgs], fn org ->
      org.id == String.to_integer(conn.params["organization_id"])
    end
  end
end
