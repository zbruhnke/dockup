defmodule DockupUi.API.BitbucketWebhookController do
  use DockupUi.Web, :controller

  require Logger

  alias DockupUi.{
    DeployService
  }

  def create(conn, %{"pullrequest" => pull_request, "repository" => %{"full_name" => repo}}) do
    [event] = get_req_header(conn, "x-event-key")
    git_url = "git@bitbucket.org:#{repo}.git"
    branch = pull_request["source"]["branch"]["name"]

    Logger.info "Received Bitbucket webhook for #{repo}:#{branch}"
    handle(conn, event, git_url, branch)
  end

  def create(conn, _params) do
    send_bad_req_response(conn)
  end

  defp handle(conn, event, git_url, branch) when event in ["pullrequest:created", "pullrequest:updated"] do
    deployment_params = %{
      "git_url" => git_url,
      "branch" => branch
    }

    deploy_service = conn.assigns[:deploy_service] || DeployService
    case deploy_service.run(deployment_params) do
      {:ok, deployment} ->
        conn
        |> put_status(:created)
        |> render(DockupUi.API.DeploymentView, "show.json", deployment: deployment)
      {:error, changeset} ->
        Logger.error "Bitbucket webhook error: #{inspect changeset.errors}"

        conn
        |> put_status(:unprocessable_entity)
        |> render(DockupUi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp handle(conn, event, _, _) when event in ["pullrequest:fulfilled", "pullrequest:rejected"] do
    conn
    |> put_status(:ok)
    |> text("ok")
  end

  defp handle(conn, _, _, _) do
    send_bad_req_response(conn)
  end

  defp send_bad_req_response(conn) do
    Logger.info "Dockup received an unknown event from Bitbucket which will be ignored."
    send_resp(conn, :bad_request, "Unknown bitbucket webhook event")
  end
end
