defmodule DockupUi.WebhookNotification do
  require Logger

  def send(deployment) do
    if webhook_url = Application.get_env(:dockup_ui, :webhook_url) do
      do_send_web_request(webhook_url, deployment)
    end
  end

  defp do_send_web_request(webhook_url, deployment) do
    spawn fn ->
      Logger.info "Sending POST request to #{webhook_url} for event #{deployment.status} of deployment: #{deployment.id}"
       request_body = Poison.encode! %{
        id: deployment.id,
        status: deployment.status,
        name: deployment.name
      }

      response = HTTPotion.post webhook_url, [
        body: request_body,
        headers: ["Content-Type": "application/json"]
      ]
       Logger.info "POST request to #{webhook_url} responded with status #{response.status_code}"
    end
  end
end
