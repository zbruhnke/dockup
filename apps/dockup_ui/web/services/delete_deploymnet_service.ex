defmodule DockupUi.DeleteDeploymentService do
  require Logger

  def run(deployment_id) do
    Logger.info "Deleted deployment with ID: #{deployment_id}"
  end
end
