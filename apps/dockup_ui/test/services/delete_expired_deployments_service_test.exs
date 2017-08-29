defmodule DockupUi.DeleteExpiredDeploymentsServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.DeleteExpiredDeploymentsService

  defmodule FakeDeleteDeploymentService do
    def run(1) do
      send self(), :deployment_deleted
    end
  end

  test "deletes deployments older than 1 day" do
    insert_at =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(1 * 60 * 60 * 24 + 1)
      |> DateTime.from_unix!()

    insert(:deployment, %{id: 1, inserted_at: insert_at})
    DeleteExpiredDeploymentsService.run(FakeDeleteDeploymentService, 1)
    assert_received :deployment_deleted
  end

  test "does not delete deployments less than 1 day ago" do
    insert(:deployment, id: 1)
    DeleteExpiredDeploymentsService.run(FakeDeleteDeploymentService, 1)
    refute_received :deployment_deleted
  end
end
