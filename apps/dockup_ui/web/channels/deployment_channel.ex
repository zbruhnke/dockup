defmodule DockupUi.DeploymentChannel do
  use Phoenix.Channel

  alias DockupUi.Endpoint

  intercept ["status_updated"]

  def update_deployment_status(deployment, payload) do
    deployment = DockupUi.API.DeploymentView.render("deployment.json", %{deployment: deployment})

    if deployment.status == "queued" do
      deployment_event("deployment_created", deployment)
    else
      deployment_event("status_updated", %{deployment: deployment, payload: payload})
    end
  end

  #============== Internal API below=============#

  def deployment_event(event, args) do
    Endpoint.broadcast("deployments:all", event, args)
  end

  def join("deployments:all", _message, socket) do
    {:ok, socket}
  end

  def handle_out("status_updated", params, socket) do
    if params.deployment.repository_id in socket.assigns.current_user_repo_ids do
      push socket, "status_updated", params
    end

    {:noreply, socket}
  end
end
