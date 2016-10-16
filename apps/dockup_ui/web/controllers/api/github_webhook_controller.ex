defmodule DockupUi.API.GithubWebhookController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    DeployService,
    Callback.Github
  }

  def create(conn, %{"pull_request" => pull_request}) do
    Github.create_github_deployment(pull_request)
    send_resp(conn, :ok, "OK")
  end

  def create(conn, params = %{"deployment" => deployment}) do
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
        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
