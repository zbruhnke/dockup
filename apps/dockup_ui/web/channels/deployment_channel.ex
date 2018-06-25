defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  alias DockupUi.Endpoint

  def update_deployment_status(deployment) do
    if deployment.status == "queued" do
      deployment_event("deployment_created", deployment)
    else
      deployment_event("status_updated", deployment)
    end
  end

  #============== Internal API below=============#

  def deployment_event(event, args) do
    Endpoint.broadcast("deployments:all", event, args)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
