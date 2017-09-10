defmodule DockupUi.DeleteDeploymentServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.DeleteDeploymentService

  defmodule FakeDeleteDeploymentJob do
    def destroy(1, _callback) do
      send self(), :ran_delete_deployment_job
      :ok
    end
  end

  test "run returns {:ok, deployment} if delete deployment job is scheduled" do
    insert(:deployment, id: 1)
    deps = [delete_deployment_job: FakeDeleteDeploymentJob]
    {:ok, deployment} = DeleteDeploymentService.run(1, deps)
    %{id: 1} = deployment
    assert_received :ran_delete_deployment_job
  end

  test "run returns {:error, deployment_id} if deployment is not found" do
    deps = [delete_deployment_job: FakeDeleteDeploymentJob]
    {:error, 1} = DeleteDeploymentService.run(1, deps)
    refute_received :ran_delete_deployment_job
  end
end
