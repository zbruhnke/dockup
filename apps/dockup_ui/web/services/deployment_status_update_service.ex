defmodule DockupUi.DeploymentStatusUpdateService do
  @moduledoc """
  This module is responsible for updating the status of the deployment
  in the DB as well as broadcasting the status update over the websocket.
  """

  require Logger
  import Ecto.Query

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentChannel
  }

  def run(status, deployment, payload, channel \\ DeploymentChannel) do
    with \
      changeset <- Deployment.changeset(deployment, changeset_map(status, payload)),
      {:ok, deployment} <- Repo.update(changeset),
      deployment <- Repo.preload(deployment, :repository),
      :ok <- channel.update_deployment_status(deployment, payload)
    do
      {:ok, deployment}
    end
  end

  defp changeset_map(:checking_urls, log_url), do: %{status: "checking_urls", log_url: log_url}
  defp changeset_map(:started, urls), do: %{status: "started", urls: urls}
  defp changeset_map(status, _payload), do: %{status: Atom.to_string(status)}
end
