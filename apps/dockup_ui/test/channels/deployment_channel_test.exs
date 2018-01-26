defmodule DockupUi.DeploymentChannelTest do
  use DockupUi.ChannelCase, async: true
  import DockupUi.Factory

  alias DockupUi.DeploymentChannel

  test "update_deployment_status broadcasts an status_updated event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    organization = insert(:organization)
    repository = insert(:repository, organization_id: organization.id)
    deployment = insert(:deployment, status: "started", repository_id: repository.id) |> Repo.preload(:repository)
    DeploymentChannel.update_deployment_status(deployment, "payload")
    repository_url = repository.git_url
    deployment_id = deployment.id
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "status_updated",
      payload: %{deployment: %{repository_url: ^repository_url, id: ^deployment_id}, payload: "payload"}
    }
  end

  test "when deployment status is 'queued' update_deployment_status sends out 'deployment_created' event" do
    DockupUi.Endpoint.subscribe("deployments:all")
    organization = insert(:organization)
    repository = insert(:repository, organization_id: organization.id)
    deployment = insert(:deployment, status: "queued", repository_id: repository.id) |> Repo.preload(:repository)
    DeploymentChannel.update_deployment_status(deployment, "payload")
    repository_url = repository.git_url
    deployment_id = deployment.id
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "deployments:all",
      event: "deployment_created",
      payload: %{repository_url: ^repository_url, id: ^deployment_id}
    }
  end
end
