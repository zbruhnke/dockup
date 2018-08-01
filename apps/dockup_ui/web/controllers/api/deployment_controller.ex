defmodule DockupUi.API.DeploymentController do
  use DockupUi.Web, :controller
  import Ecto.Query

  alias DockupUi.{
    Deployment,
    DeployService,
    HibernateDeploymentService,
    WakeUpDeploymentService,
    DeleteDeploymentService,
    Repo
  }

  def index(conn, _params) do
    query =
      from d in Deployment,
      order_by: [desc: :inserted_at],
      limit: 100
    deployments = Repo.all(query)
    render(conn, "index.json", deployments: deployments)
  end

  def create(conn, deployment_params) do
    deploy_service = conn.assigns[:deploy_service] || DeployService

    case deploy_service.run(deployment_params) do
      {:ok, %{deployment: deployment}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", api_deployment_path(conn, :show, deployment))
        |> render("show.json", deployment: deployment)
      {:error, :deployment, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
      {:error, :start_containers, error} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{errors: [error]})
    end
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render(conn, "show.json", deployment: deployment)
  end

  def delete(conn, destroy_params) do
    delete_deployment_service = conn.assigns[:delete_deployment_service] || DeleteDeploymentService
    deployment_id = destroy_params["id"]

    case delete_deployment_service.run(deployment_id) do
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

  def hibernate(conn, %{"deployment_id" => id}) do
    case HibernateDeploymentService.run(id) do
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

  def wake_up(conn, %{"deployment_id" => id}) do
    case WakeUpDeploymentService.run(id) do
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
end
