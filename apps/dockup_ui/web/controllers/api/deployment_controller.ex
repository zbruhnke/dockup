defmodule DockupUi.API.DeploymentController do
  use DockupUi.Web, :controller
  import Ecto.Query

  alias DockupUi.{
    DeployService,
    DeleteDeploymentService,
    Repo
  }

  def index(conn, _params) do
    deployments =
      conn.assigns[:current_user]
      |> Ecto.assoc([:organizations, :repositories, :deployments])
      |> preload(:repository)
      |> order_by([d], desc: d.inserted_at)
      |> Repo.all

    render(conn, "index.json", deployments: deployments)
  end

  def create(conn,  %{"git_url" => git_url, "branch" => branch}) do
    repository = repository_with_git_url(conn.assigns.current_user, git_url)
    deploy_service = conn.assigns[:deploy_service] || DeployService

    case deploy_service.run(repository, branch) do
      {:ok, deployment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", api_deployment_path(conn, :show, deployment))
        |> render("show.json", deployment: Repo.preload(deployment, :repository))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    deployment = current_user_deployment(conn.assigns.current_user, id)

    render(conn, "show.json", deployment: deployment)
  end

  def delete(conn, %{"id" => id}) do
    delete_deployment_service = conn.assigns[:delete_deployment_service] || DeleteDeploymentService
    deployment = current_user_deployment(conn.assigns.current_user, id)

    case delete_deployment_service.run(deployment) do
      {:ok, deployment} ->
        conn
        |> put_status(:ok)
        |> put_resp_header("location", api_deployment_path(conn, :show, deployment))
        |> render("show.json", deployment: deployment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp repository_with_git_url(user, git_url) do
    [repository] =
      user
      |> Ecto.assoc([:organizations, :repositories])
      |> where([r], r.git_url == ^git_url)
      |> Repo.all()

    repository
  end

  defp current_user_deployment(user, id) do
    user
    |> Ecto.assoc([:organizations, :repositories, :deployments])
    |> where([d], d.id == ^id)
    |> preload(:repository)
    |> Repo.one!()
  end
end
