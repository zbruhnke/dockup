defmodule DockupUi.Callback do
  @moduledoc """
  Triggers callbacks on implementors of CallbackProtocol
  and calls DeploymentStatusUpdateService with the given event.
  """

  require Logger

  alias DockupUi.{
    DeploymentStatusUpdateService,
    CallbackProtocol,
    Deployment,
    Repo,
    SlackWebhook
  }

  def lambda(deployment, callback_data, status_update_service \\ DeploymentStatusUpdateService) do
    fn
      event, payload ->
        # Reload deployment
        deployment = Repo.get!(Deployment, deployment.id)

        status_update_service.run(event, deployment.id, payload)

        # Trigger callback by spawning a new thread, we don't care if fails
        spawn fn ->
          try do
            send_slack_message(event, deployment, payload)
            apply(CallbackProtocol, event, [callback_data, deployment, payload])
          rescue
            UndefinedFunctionError -> Logger.error "Unknown callback event triggered: #{inspect event}"
          end
        end
    end
  end

  defp send_slack_message(:started, deployment, payload) when is_list payload do
    service_urls =
      payload
      |> Enum.map(& "<http://#{&1}>")
      |> Enum.join(", ")
    if url = System.get_env("SLACK_WEBHOOK_URL") do
      message = "Branch `#{deployment.branch}` deployed at #{service_urls}"
      SlackWebhook.send_message(url, message)
    end
  end

  defp send_slack_message(_, _, _) do
    :ok
  end
end
