defmodule DockupUi.DeploymentChannelTest do
  use DockupUi.ChannelCase, async: true
  import DockupUi.Factory

  alias DockupUi.DeploymentChannel

  test "update_deployment_status broadcasts a status_updated event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    deployment = insert(:deployment, status: "started")
    DeploymentChannel.update_deployment_status(deployment)
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "status_updated",
      payload: ^deployment
    }
  end

  test "when deployment status is 'queued' update_deployment_status sends out 'deployment_created' event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    deployment = insert(:deployment, status: "queued")
    DeploymentChannel.update_deployment_status(deployment)
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "deployment_created",
      payload: ^deployment
    }
  end
end
