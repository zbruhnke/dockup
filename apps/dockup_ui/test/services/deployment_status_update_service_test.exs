defmodule DeploymentStatusUpdateServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  defmodule FakeChannel do
    def update_deployment_status(_params) do
      send self(), :status_updated_on_channel
      :ok
    end
  end

  test "run returns {:ok, deployment} after updating the DB and broadcasting status update of deployment" do
    deployment = insert(:deployment)
    {:ok, updated_deployment} = DockupUi.DeploymentStatusUpdateService.run("foo", deployment.id, FakeChannel)

    assert updated_deployment.status == "foo"
    assert updated_deployment.urls == nil
    assert_received :status_updated_on_channel
  end

  test "run returns {:ok, deployment}" do
    deployment = insert(:deployment)
    {:ok, _deployment} =
      DockupUi.DeploymentStatusUpdateService.run("started", deployment.id, FakeChannel)

    updated_deployment = DockupUi.Repo.get(DockupUi.Deployment, deployment.id)

    assert updated_deployment.status == "started"
    assert_received :status_updated_on_channel
  end
end
