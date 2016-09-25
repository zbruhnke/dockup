defmodule DockupUi.Callback do
  @moduledoc """
  Triggers callbacks on implementors of CallbackProtocol
  and calls DeploymentStatusUpdateService with the given event.
  """

  require Logger

  alias DockupUi.{
    DeploymentStatusUpdateService,
    CallbackProtocol,
    Deployment,
    Repo
  }

  def lambda(deployment, callback_data, status_update_service \\ DeploymentStatusUpdateService) do
    fn
      event, payload ->
        # Reload deployment
        deployment = Repo.get!(Deployment, deployment.id)

        status_update_service.run(event, deployment.id, payload)

        # Trigger callback by spawning a new thread, we don't care if fails
        spawn fn ->
          try do
            apply(CallbackProtocol, event, [callback_data, deployment, payload])
          rescue
            UndefinedFunctionError -> Logger.error "Unknown callback event triggered: #{inspect event}"
          end
        end
    end
  end
end
