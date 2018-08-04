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

  def deployment_event(event, deployment) do
    deployment_json = DockupUi.API.DeploymentView.render("deployment.json", %{deployment: deployment})
    Endpoint.broadcast("deployments:all", event, deployment_json)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end
end
