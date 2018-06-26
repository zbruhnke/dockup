defmodule DeployServiceTest do
  use DockupUi.ModelCase, async: true

  import DockupUi.Factory

  defmodule FakeDeployQueue do
    def enqueue(_params) do
      send self(), :queued_deployment
      :ok
    end
  end

  test "run returns {:ok, deployment} if deployment is saved and the job is scheduled" do
    deps = [deployment_queue: FakeDeployQueue]
    insert(:whitelisted_url, git_url: "foo")
    {:ok, deployment} = DockupUi.DeployService.run(%{git_url: "foo", branch: "bar"}, deps)
    %{git_url: "foo", branch: "bar"} = deployment
    assert_received :queued_deployment
  end

  test "run returns {:error, changeset} if deployment cannot be saved" do
    deps = [deployment_queue: FakeDeployQueue]
    {:error, changeset} = DockupUi.DeployService.run(%{branch: "bar"}, deps)
    assert {:git_url, {"can't be blank", [validation: :required]}} in changeset.errors
    refute_received :queued_deployment
  end

  test "run returns {:error, changeset} if git url is not whitelisted" do
    deps = [deployment_queue: FakeDeployQueue]
    {:error, changeset} = DockupUi.DeployService.run(%{git_url: "not_whitelisted",branch: "bar"}, deps)
    assert {:git_url, {"is not whitelisted for deployment", []}} in changeset.errors
    refute_received :queued_deployment
  end
end
