defmodule DockupUi.DeleteDeploymentServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.{
    DeleteDeploymentService
  }

  defmodule FakeDeleteDeploymentJob do
    def destroy(1, _callback) do
      send self(), :ran_delete_deployment_job
      :ok
    end
  end

  test "run returns {:ok, deployment} if delete deployment job is scheduled" do
    organization = insert(:organization)
    repository = insert(:repository, organization_id: organization.id)
    deployment = insert(:deployment, id: 1, repository_id: repository.id)
    deps = [delete_deployment_job: FakeDeleteDeploymentJob]
    {:ok, %DockupUi.Deployment{id: 1, deleted_at: deleted_at}} = DeleteDeploymentService.run(deployment, deps)
    refute is_nil(deleted_at)
    assert_received :ran_delete_deployment_job
  end
end
