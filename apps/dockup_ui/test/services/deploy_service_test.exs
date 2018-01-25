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
    insert(:repository, git_url: "foo", organization_id: org.id)
    {:ok, deployment} = DockupUi.DeployService.run(%{git_url: "foo", branch: "bar"}, nil, deps)
    %{git_url: "foo", branch: "bar"} = deployment
    assert_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if deployment cannot be saved" do
    deps = [deploy_job: FakeDeployJob]
    {:error, changeset} = DockupUi.DeployService.run(%{branch: "bar"}, nil, deps)
    assert {:git_url, {"can't be blank", [validation: :required]}} in changeset.errors
    refute_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if git url is not whitelisted" do
    deps = [deploy_job: FakeDeployJob]
    {:error, changeset} = DockupUi.DeployService.run(%{git_url: "not_whitelisted",branch: "bar"}, nil, deps)
    assert {:git_url, {"is not whitelisted for deployment", []}} in changeset.errors
    refute_received :ran_deploy_job
  end
end
