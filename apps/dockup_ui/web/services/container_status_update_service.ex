defmodule DockupUi.ContainerStatusUpdateService do
  @moduledoc """
  This module is responsible for broadcasting the status of a container
  """

  alias DockupUi.{
    DeploymentChannel
  }

  def run(container) do
    DeploymentChannel.update_container_status(container)
  end
end
