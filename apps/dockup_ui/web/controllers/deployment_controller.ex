defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  alias DockupUi.Deployment

  def new(conn, _params) do
    render conn, "new.html"
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render conn, "show.html", deployment: deployment
  end
end
