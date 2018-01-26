defmodule DeploymentStatusUpdateServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  defmodule FakeChannel do
    def update_deployment_status(_params, _payload) do
      send self(), :status_updated_on_channel
      :ok
    end
  end

  test "run returns {:ok, deployment} after updating the DB and broadcasting status update of deployment" do
    deployment = insert(:deployment)
    {:ok, updated_deployment} = DockupUi.DeploymentStatusUpdateService.run(:foo, deployment, "fake_payload", FakeChannel)

    assert updated_deployment.status == "foo"
    assert updated_deployment.urls == nil
    assert_received :status_updated_on_channel
  end

  test "run returns {:ok, deployment} and persists payload" do
    urls = [
      "http://random_string_1.dockup.codemancers.com",
      "http://random_string_2.dockup.codemancers.com"
    ]

    deployment = insert(:deployment)
    {:ok, _deployment} =
      DockupUi.DeploymentStatusUpdateService.run(:started, deployment, urls, FakeChannel)

    updated_deployment = DockupUi.Repo.get(DockupUi.Deployment, deployment.id)

    assert updated_deployment.status == "started"
    assert updated_deployment.urls == urls
    assert_received :status_updated_on_channel
  end

  test "run persists log_url when checking_urls" do
    deployment = insert(:deployment)
    payload = "log_url"

    DockupUi.DeploymentStatusUpdateService.run(:checking_urls, deployment, payload, FakeChannel)

    updated_deployment = DockupUi.Repo.get(DockupUi.Deployment, deployment.id)

    assert updated_deployment.status == "checking_urls"
    assert updated_deployment.log_url == payload
    assert_received :status_updated_on_channel
  end
end
