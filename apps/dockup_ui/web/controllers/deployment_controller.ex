defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  import Ecto.Query

  def new(conn, _params) do
    repositories =
      conn.assigns[:current_user]
      |> Ecto.assoc([:organizations, :repositories])
      |> select([r], r.git_url)
      |> Repo.all

    render conn, "new.html", repositories_json: Poison.encode!(repositories)
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"id" => id}) do
    deployment = current_user_deployment(conn.assigns.current_user, id)
    render conn, "show.html", deployment: deployment
  end

  def home(conn, _params) do
    if get_session(conn, :current_user) do
      redirect(conn, to: deployment_path(conn, :new))
    else
      render(conn, "home.html", layout: {DockupUi.LayoutView, "home.html"})
    end
  end

  defp current_user_deployment(user, id) do
    user
    |> Ecto.assoc([:organizations, :repositories, :deployments])
    |> where([d], d.id == ^id)
    |> preload(:repository)
    |> Repo.one!()
  end
end
