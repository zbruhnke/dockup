defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  def update_deployment_status(deployment, payload) do
    if deployment.status == "queued" do
      deployment_event("deployment_created", deployment)
    else
      deployment_event("status_updated", %{deployment: deployment, payload: payload})
    end
  end

  #============== Internal API below=============#

  def deployment_event(event, args) do
    DockupUi.Endpoint.broadcast("deployments:all", event, args)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
