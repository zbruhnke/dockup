defmodule DockupUi.DeploymentQueueTest do
  use DockupUi.ModelCase, async: false
  import DockupUi.Factory

  alias DockupUi.{
    DeploymentQueue
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(DockupUi.Repo, {:shared, self()})
  end

  @name TestDeploymentQueue

  defmodule FakeBackend do
    def deploy({pid, deployment}, _fn) do
      send pid, {deployment, :os.system_time()}
    end
  end

  test "does not deploy from queue when there are max no of concurrent deployments " do
    for _ <- 1..6 do
      insert(:deployment, status: "started")
    end

    {:ok, _pid} = DeploymentQueue.start_link(FakeBackend, @name)
    DeploymentQueue.enqueue({{self(), :new_deployment}, nil}, @name)
    assert DeploymentQueue.get_queue(@name) == [{{self(), :new_deployment}, nil}]
    refute_receive {:new_deployment, _}
  end

  test "deploys from tail of queue when there aren't enough concurrent deployments" do
    for _ <- 1..4 do
      insert(:deployment, status: "started")
    end

    {:ok, _pid} = DeploymentQueue.start_link(FakeBackend, @name)
    DeploymentQueue.enqueue({{self(), :tail_deployment}, nil}, @name)
    DeploymentQueue.enqueue({{self(), :head_deployment}, nil}, @name)
    assert_receive {:tail_deployment, t1}
    assert_receive {:head_deployment, t2}
    assert t2 > t1
  end
end
