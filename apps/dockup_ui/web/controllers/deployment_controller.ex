defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    Deployment,
    Blueprint
  }

  import Ecto.Query

  def new(conn, _params) do
    query =
      from b in Blueprint,
      preload: [:container_specs]

    # TODO: This should be all blueprints and
    # let front end choose blueprint from a UI
    # for now, there's only one blueprint which is loaded via seed script.
    blueprint = Repo.one!(query)
    render conn, "new.html", blueprint: blueprint
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render conn, "show.html", deployment: deployment
  end
end
