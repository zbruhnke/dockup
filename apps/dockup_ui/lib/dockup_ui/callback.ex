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

    event = use_restarting_event(deployment_id, event)

    {:ok, deployment} = status_update_service.run(event, deployment_id)

    case deployment.status do
      "started" ->
        send_slack_message(deployment, slack_webhook)

      "waiting_for_urls" ->
        process_deployment_queue(deployment_queue)

      "deleted" ->
        process_deployment_queue(deployment_queue)

      "restarting" ->
        requeue_deployment(deployment, deployment_queue)

      "hibernated" ->
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
      # TODO: This will change to "Deployed <tag name> of <project> : <dockup deployment url>"
      message = "Branch `#{deployment.branch}` deployed at <#{deployment_url}>"
      slack_webhook.send_message(url, message)
    end
  end

  defp use_restarting_event(deployment_id, event) when event in ["deleted", "deleting"] do
    deployment = Repo.get!(Deployment, deployment_id)

    if deployment.status == "restarting" do
      "restarting"
    else
      "deleted"
    end
  end
  defp use_restarting_event(_, event), do: event

  defp requeue_deployment(deployment, deployment_queue) do
    deployment
    |> Deployment.changeset(%{status: "queued"})
    |> Repo.update!()

    deployment_queue.enqueue(deployment.id)
  end
end
