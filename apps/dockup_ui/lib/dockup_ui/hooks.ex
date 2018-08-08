defmodule DockupUi.Hooks do
  require Logger

  alias DockupUi.{
    SlackNotification,
    WebhookNotification
  }

  def do_after("started", deployment) do
    SlackNotification.send(deployment)
    WebhookNotification.send(deployment)
  end

  def do_after(_, _) do
    :ok
  end
end
