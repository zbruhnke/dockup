defmodule DockupUi.ConfigController do
  use DockupUi.Web, :controller

  alias DockupUi.Subdomain

  def index(conn, _params) do
    subdomains = Repo.all(Subdomain)
    render(conn, "index.html", subdomains: subdomains)
  end
end
