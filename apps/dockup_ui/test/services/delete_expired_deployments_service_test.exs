defmodule DockupUi.DeleteExpiredDeploymentsServiceTest do
  use DockupUi.ModelCase, async: true
  use Timex
  import DockupUi.Factory

  alias DockupUi.DeleteExpiredDeploymentsService

  defmodule FakeDeleteDeploymentService do
    def run(1) do
      send self, :deployment_deleted
    end
  end

  test "deletes deployments older than 1 day" do
    insert_at =
      :erlang.universaltime
      |> :calendar.datetime_to_gregorian_seconds
      |> Kernel.-(1 * 60 * 60 * 24 + 1)
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

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
