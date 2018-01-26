defmodule DeployServiceTest do
  use DockupUi.ModelCase, async: true

  import DockupUi.Factory

  defmodule FakeDeployJob do
    def deploy(_params, _callback) do
      send self(), :ran_deploy_job
      :ok
    end
  end

  test "run returns {:ok, deployment} if deployment is saved and the job is scheduled" do
    deps = [deploy_job: FakeDeployJob]
    org = insert(:organization)
    repository = insert(:repository, git_url: "foo", organization_id: org.id)
    {:ok, deployment} = DockupUi.DeployService.run(repository, "bar", deps)
    assert deployment.repository_id == repository.id
    assert deployment.branch == "bar"
    assert_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if deployment cannot be saved" do
    deps = [deploy_job: FakeDeployJob]
    org = insert(:organization)
    repository = insert(:repository, git_url: "foo", organization_id: org.id)
    {:error, changeset} = DockupUi.DeployService.run(repository, "", deps)
    assert {:branch, {"can't be blank", [validation: :required]}} in changeset.errors
    refute_received :ran_deploy_job
  end
end
