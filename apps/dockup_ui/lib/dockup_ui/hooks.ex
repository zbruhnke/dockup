defmodule DockupUi.Hooks do
  require Logger

  alias DockupUi.{
    SlackNotification,
    WebhookNotification,
    Metrics
  }

  def do_after("started", deployment) do
    SlackNotification.send(deployment)
    WebhookNotification.send(deployment)
    deployment.containers |> length |> Metrics.send
  end

  def do_after(_, _) do
    :ok
  end
end
