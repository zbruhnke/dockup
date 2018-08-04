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

  def update_container_status(container) do
    container_event("status_updated", container)
  end

  #============== Internal API below=============#

  def deployment_event(event, deployment) do
    deployment_json = DockupUi.API.DeploymentView.render("deployment.json", %{deployment: deployment})
    Endpoint.broadcast("deployments:all", event, deployment_json)
  end

  def container_event(event, container) do
    container_json = %{id: container.id, status: container.status}
    Endpoint.broadcast("deployments:#{container.deployment_id}", event, container_json)
  end

  def join("deployments:" <> _, _message, socket) do
    {:ok, socket}
  end
end
