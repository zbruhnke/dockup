defmodule DockupUi.Callback do
  @moduledoc """
  Triggers callbacks on implementors of CallbackProtocol
  and calls DeploymentStatusUpdateService with the given event.
  """

  require Logger

  alias DockupUi.{
    DeploymentStatusUpdateService,
    SlackWebhook,
    Deployment,
    Repo,
    DeploymentQueue
  }

  @valid_states ~w(queued starting waiting_for_urls started hibernating
    hibernated waking_up deleting deleted failed)

  def update_status(deployment_id, event, deps \\ %{})
      when event in @valid_states do
    status_update_service = deps[:status_update_service] || DeploymentStatusUpdateService
    slack_webhook = deps[:slack_webhook] || SlackWebhook
    deployment_queue = deps[:deployment_queue] || DeploymentQueue

    {:ok, deployment} = status_update_service.run(event, deployment_id)

    case deployment.status do
      "started" ->
        send_slack_message(deployment, slack_webhook)

      "waiting_for_urls" ->
        process_deployment_queue(deployment_queue)

      "deleted" ->
        process_deployment_queue(deployment_queue)

      _ ->
        :ok
    end
  end

  def set_urls(deployment_id, urls) do
    Deployment
    |> Repo.get!(deployment_id)
    |> Deployment.changeset(%{urls: urls})
    |> Repo.update!()
  end

  def set_log_url(deployment_id, log_url) do
    Deployment
    |> Repo.get!(deployment_id)
    |> Deployment.changeset(%{log_url: log_url})
    |> Repo.update!()
  end

  defp process_deployment_queue(deployment_queue) do
    if deployment_queue.alive?() do
      deployment_queue.process_queue()
    end
  end

  defp send_slack_message(deployment, slack_webhook) do
    deployment_url =
      DockupUi.Router.Helpers.deployment_url(DockupUi.Endpoint, :show, deployment.id)

    if url = Application.get_env(:dockup_ui, :slack_webhook_url) do
      # TODO: change this message to "Deployed <name> of <project> : <dockup deployment url>"
      message = "Dockup has a new deployment at <#{deployment_url}>"
      slack_webhook.send_message(url, message)
    end
  end
end
