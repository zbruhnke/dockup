defmodule DockupUi.API.DeploymentController do
  use DockupUi.Web, :controller
  import Ecto.Query

  alias DockupUi.{
    Deployment,
    DeployService,
    Repo,
    Callback.Web
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
    callback_data = %Web{callback_url: deployment_params["callback_url"]}

    case deploy_service.run(deployment_params, callback_data) do
      {:ok, deployment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", api_deployment_path(conn, :show, deployment))
        |> render("show.json", deployment: deployment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    deployment = Repo.get!(Deployment, id)
    render(conn, "show.json", deployment: deployment)
  end
end
