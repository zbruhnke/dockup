defmodule DockupUi.DeploymentStatusUpdateService do
  @moduledoc """
  This module is responsible for updating the status of the deployment
  in the DB as well as broadcasting the status update over the websocket.
  """

  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentChannel
  }

  def run(deployment) do
    DeploymentChannel.update_deployment_status(deployment)
  end

  def run(status, deployment_id, channel \\ DeploymentChannel) do
    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      changeset <- Deployment.changeset(deployment, %{status: status}),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- channel.update_deployment_status(deployment)
    do
      {:ok, deployment}
    end
  end
end
