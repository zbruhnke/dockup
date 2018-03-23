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
    def deploy(deployment, fun) do
      send fun.(nil, nil), {deployment.id, :os.system_time()}
    end
  end

  defmodule FakeCallback do
    def lambda(_deployment, pid) do
      fn _, _ -> pid end
    end
  end

  test "does not deploy from queue when there are max no of concurrent deployments" do
    for _ <- 1..4 do
      insert(:deployment, status: "started")
    end
    for _ <- 1..2 do
      insert(:deployment, status: "processing")
    end
    deployment = insert(:deployment, status: "queued", id: 100)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, FakeCallback)
    DeploymentQueue.enqueue({deployment, self()}, @name)
    assert DeploymentQueue.get_queue(@name) == [{deployment, self()}]
    refute_receive {100, _}
  end

  test "does not deploy from queue when there are max no of concurrent builds" do
    insert(:deployment, status: "starting")
    insert(:deployment, status: "starting")

    # Even if there is only one started deployment, there are two builds in
    # "starting" state above
    insert(:deployment, status: "started")

    deployment = insert(:deployment, status: "queued", id: 100)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, FakeCallback)
    DeploymentQueue.enqueue({deployment, self()}, @name)
    assert DeploymentQueue.get_queue(@name) == [{deployment, self()}]
    refute_receive {100, _}
  end

  test "deploys from tail of queue when there aren't enough concurrent deployments" do
    for _ <- 1..4 do
      insert(:deployment, status: "started")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "deployment_deleted")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "queued")
    end
    tail_deployment = insert(:deployment, status: "queued", id: 100)
    head_deployment = insert(:deployment, status: "queued", id: 200)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, FakeCallback)
    DeploymentQueue.enqueue({tail_deployment, self()}, @name)
    DeploymentQueue.enqueue({head_deployment, self()}, @name)
    assert_receive {100, t1}
    assert_receive {200, t2}
    assert t2 > t1
  end

  test "ignores deleted deployments when processing queue" do
    for _ <- 1..4 do
      insert(:deployment, status: "started")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "deployment_deleted")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "queued")
    end
    tail_deployment = insert(:deployment, status: "deployment_deleted", id: 100)
    head_deployment = insert(:deployment, status: "queued", id: 200)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, FakeCallback)
    DeploymentQueue.enqueue({tail_deployment, self()}, @name)
    DeploymentQueue.enqueue({head_deployment, self()}, @name)
    refute_receive {100, _}
    assert_receive {200, _}
  end
end
