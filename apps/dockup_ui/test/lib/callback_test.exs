defmodule DockupUi.CallbackTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.{
    Deployment,
    Callback
  }

  defmodule FakeStatusUpdateService do
    def run(status, 1) do
      send self(), :status_updated

      Deployment
      |> Repo.get!(1)
      |> Deployment.changeset(%{status: status})
      |> Repo.update
    end
  end

  defmodule FakeSlackWebhook do
    def send_message(url, message) do
      send self(), {url, message}
    end
  end

  test "update_status runs DeploymentStatusUpdateService" do
    insert(:deployment, id: 1)

    Callback.update_status(1, "queued", %{status_update_service: FakeStatusUpdateService})
    assert_received :status_updated
  end

  test "update_status sends a slack message when deployment is started" do
    Application.put_env(:dockup_ui, :slack_webhook_url, "https://slackurl")
    insert(:deployment, id: 1)

    Callback.update_status(1, "started", %{status_update_service: FakeStatusUpdateService, slack_webhook: FakeSlackWebhook})
    message = "Dockup has a new deployment at <http://localhost:4001/deployments/1>"
    assert_received {"https://slackurl", ^message}
  end
end
