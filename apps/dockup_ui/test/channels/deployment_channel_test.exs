defmodule DockupUi.DeploymentChannelTest do
  use DockupUi.ChannelCase, async: true
  import DockupUi.Factory

  alias DockupUi.DeploymentChannel

  test "update_deployment_status broadcasts a status_updated event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    blueprint = insert(:blueprint)
    deployment = insert(:deployment, %{status: "started"}, %{blueprint_id: blueprint.id})
    DeploymentChannel.update_deployment_status(deployment)

    expected_payload = %{
      blueprint_name: blueprint.name,
      deployed_at: nil,
      id: deployment.id,
      inserted_at: deployment.inserted_at,
      name: deployment.name,
      status: "started",
      updated_at: deployment.updated_at
    }
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "status_updated",
      payload: ^expected_payload
    }
  end

  test "when deployment status is 'queued' update_deployment_status sends out 'deployment_created' event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    blueprint = insert(:blueprint)
    deployment = insert(:deployment, %{status: "queued"}, %{blueprint_id: blueprint.id})
    DeploymentChannel.update_deployment_status(deployment)

    expected_payload = %{
      blueprint_name: blueprint.name,
      deployed_at: nil,
      id: deployment.id,
      inserted_at: deployment.inserted_at,
      name: deployment.name,
      status: "queued",
      updated_at: deployment.updated_at
    }
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "deployment_created",
      payload: ^expected_payload
    }
  end
end
