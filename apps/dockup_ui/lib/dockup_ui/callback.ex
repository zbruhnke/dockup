defmodule DockupUi.Callback do
  @moduledoc """
  Calls DeploymentStatusUpdateService with the given event.
  """

  alias DockupUi.{
    DeploymentStatusUpdateService
  }

  def lambda(callback_params, status_update_service \\ DeploymentStatusUpdateService) do
    fn
      event, payload ->
        status_update_service.run(event, callback_params.deployment, payload)
    end
  end
end
