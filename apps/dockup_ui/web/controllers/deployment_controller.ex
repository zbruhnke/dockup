defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    Deployment,
    WhitelistedUrl
  }

  import Ecto.Query

  def new(conn, _params) do
    query =
      from w in WhitelistedUrl,
      select: w.git_url

    whitelisted_urls = Repo.all(query)
    render conn, "new.html", whitelisted_urls_json: Poison.encode!(whitelisted_urls)
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render conn, "show.html", deployment: deployment
  end

  def home(conn, _params) do
    render(conn, "home.html", layout: {DockupUi.LayoutView, "home.html"})
  end
end
