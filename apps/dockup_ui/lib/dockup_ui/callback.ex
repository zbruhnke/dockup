defmodule DockupUi.Callback do
  @moduledoc """
  Calls DeploymentStatusUpdateService with the given event.
  """

  require Logger

  alias DockupUi.{
    DeploymentStatusUpdateService
  }

  def lambda(deployment, status_update_service \\ DeploymentStatusUpdateService) do
    fn
      event, payload -> status_update_service.run(event, deployment, payload)
    end
  end
end
