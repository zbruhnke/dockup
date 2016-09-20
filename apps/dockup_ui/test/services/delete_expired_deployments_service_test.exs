defmodule DockupUi.DeleteExpiredDeploymentsServiceTest do
  use DockupUi.ModelCase, async: true
  use Timex
  import DockupUi.Factory

  alias DockupUi.DeleteExpiredDeploymentsService

  test "cleanup " do
    defmodule FakeDeleteDeploymentService do
      def run(1) do
        send self, :deployment_deleted
      end
    end

    insert_at =
      :erlang.universaltime
      |> :calendar.datetime_to_gregorian_seconds
      |> Kernel.-(1 * 60 * 60 * 24 + 1)
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    insert(:deployment, %{id: 1, inserted_at: insert_at})
    DeleteExpiredDeploymentsService.run(FakeDeleteDeploymentService)
    assert_received :deployment_deleted
  end
end
