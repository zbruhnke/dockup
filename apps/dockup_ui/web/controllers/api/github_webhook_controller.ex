defmodule DockupUi.API.GithubWebhookController do
  use DockupUi.Web, :controller

  require Logger

  alias DockupUi.{
    DeployService,
    Callback.Github
  }

  def create(conn, %{"pull_request" => pull_request, "action" => action})
    when action in ["opened", "synchronize", "reopened"] do

    Logger.info "Received Github webhook for opened/updated pull request"
    Github.create_github_deployment(pull_request)
    send_resp(conn, :ok, "OK")
  end

  def create(conn, params = %{"deployment" => deployment}) do
    Logger.info "Received Github webhook for creating a new deployment"
    deployment_id = deployment["id"]
    repo_full_name = params["repository"]["full_name"]
    callback_data = %Github{deployment_id: deployment_id, repo_full_name: repo_full_name}
    deployment_params = %{
      "git_url" => params["repository"]["clone_url"],
      "branch" => deployment["ref"]
    }

    deploy_service = conn.assigns[:deploy_service] || DeployService
    case deploy_service.run(deployment_params, callback_data) do
      {:ok, deployment} ->
        conn
        |> put_status(:created)
        |> render(DockupUi.API.DeploymentView, "show.json", deployment: deployment)
      {:error, changeset} ->
        Logger.error "Github webhook error: #{inspect changeset.errors}"

        Task.async(fn ->
          Github.update_deployment_status("failure", nil, repo_full_name, deployment_id)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def create(conn, _params) do
    Logger.info "Dockup received an unknown event from Github which will be ignored."
    send_resp(conn, :bad_request, "Unknown github webhook event")
  end
end
