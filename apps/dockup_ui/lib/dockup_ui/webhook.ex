defmodule DockupUi.Webhook do
  require Logger

  def send_webhook_request(webhook_url, deployment) do
    spawn fn ->
      Logger.info "Sending POST request to #{webhook_url} for event #{deployment.status} of deployment: #{deployment.id}"

      request_body = Poison.encode! %{
        id: deployment.id,
        status: deployment.status,
        git_url: deployment.git_url,
        branch: deployment.branch
      }

      response = HTTPotion.post webhook_url, [
        body: request_body,
        headers: ["Content-Type": "application/json"]
      ]

      Logger.info "POST request to #{webhook_url} responded with status #{response.status_code}"
    end
  end
end
