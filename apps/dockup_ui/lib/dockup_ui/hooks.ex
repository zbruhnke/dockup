defmodule DockupUi.Hooks do
  require Logger

  alias DockupUi.{
    SlackWebhook,
    Webhook
  }

  def do_after("started", deployment) do
    SlackWebhook.send_deployment_message(deployment)
    Webhook.send_webhook_request(deployment)
  end

  def do_after(_, _) do
    :ok
  end
end
