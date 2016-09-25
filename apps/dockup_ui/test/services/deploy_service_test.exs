defmodule DeployServiceTest do
  use DockupUi.ModelCase, async: true

  defmodule FakeDeployJob do
    def spawn_process(_params, _callback) do
      send self, :ran_deploy_job
      :ok
    end
  end

  defmodule FakeWhitelistStore do
    def whitelisted?("foo"), do: true
    def whitelisted?("not_whitelisted"), do: false
  end

  test "run returns {:ok, deployment} if deployment is saved and the job is scheduled" do
    deps = [deploy_job: FakeDeployJob, whitelist_store: FakeWhitelistStore]
    {:ok, deployment} = DockupUi.DeployService.run(%{git_url: "foo", branch: "bar"}, nil, deps)
    %{git_url: "foo", branch: "bar"} = deployment
    assert_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if deployment cannot be saved" do
    {:error, changeset} = DockupUi.DeployService.run(%{branch: "bar"}, nil)
    assert {:git_url, {"can't be blank", []}} in changeset.errors
    refute_received :ran_deploy_job
  end

  test "run returns {:error, changeset} if git url is not whitelisted" do
    {:error, changeset} = DockupUi.DeployService.run(%{git_url: "not_whitelisted",branch: "bar"}, nil)
    assert {:git_url, {"is not whitelisted for deployment", []}} in changeset.errors
    refute_received :ran_deploy_job
  end
end
