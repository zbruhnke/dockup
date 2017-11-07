defmodule DockupUi.DeleteExpiredDeploymentsServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory
  import ExUnit.CaptureIO

  alias DockupUi.DeleteExpiredDeploymentsService

  defmodule FakeDeleteDeploymentService do
    def run(1) do
      IO.write "Deployment deleted"
    end
  end

  test "deletes deployments older than 1 day" do
    insert_at =
      DateTime.utc_now()
      |> DateTime.to_naive()
      |> NaiveDateTime.add(-(60 * 60 * 24 + 1))
      |> DateTime.from_naive!("Etc/UTC")

    insert(:deployment, %{id: 1, inserted_at: insert_at})

    assert capture_io(fn ->
      DeleteExpiredDeploymentsService.run(FakeDeleteDeploymentService, 1)
    end) == "Deployment deleted"
  end

  test "does not delete deployments less than 1 day ago" do
    insert(:deployment, id: 1)
    assert capture_io(fn ->
      DeleteExpiredDeploymentsService.run(FakeDeleteDeploymentService, 1)
    end) != "Deployment deleted"
  end
end
