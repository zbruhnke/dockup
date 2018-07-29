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
    def deploy(deployment, pid) do
      send pid, {deployment.id, :os.system_time()}
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

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, self())
    DeploymentQueue.enqueue(deployment.id, @name)
    assert DeploymentQueue.get_queue(@name) == [deployment.id]
    refute_receive {100, _}
  end

  test "does not deploy from queue when there are max no of concurrent builds" do
    insert(:deployment, status: "starting")
    insert(:deployment, status: "starting")

    # Even if there is only one started deployment, there are two builds in
    # "starting" state above
    insert(:deployment, status: "started")

    deployment = insert(:deployment, status: "queued", id: 100)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, self())
    DeploymentQueue.enqueue(deployment.id, @name)
    assert DeploymentQueue.get_queue(@name) == [deployment.id]
    refute_receive {100, _}
  end

  test "deploys from tail of queue when there aren't enough concurrent deployments" do
    for _ <- 1..3 do
      insert(:deployment, status: "started")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "deleted")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "queued")
    end
    tail_deployment = insert(:deployment, status: "queued", id: 100)
    head_deployment = insert(:deployment, status: "queued", id: 200)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, self())
    DeploymentQueue.enqueue(tail_deployment.id, @name)
    DeploymentQueue.enqueue(head_deployment.id, @name)
    assert_receive {100, t1}
    assert_receive {200, t2}
    assert t2 > t1
  end

  test "ignores deleted deployments when processing queue" do
    for _ <- 1..4 do
      insert(:deployment, status: "started")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "deleted")
    end
    for _ <- 1..4 do
      insert(:deployment, status: "queued")
    end
    tail_deployment = insert(:deployment, status: "deleted", id: 100)
    head_deployment = insert(:deployment, status: "queued", id: 200)

    {:ok, _pid} = DeploymentQueue.start_link(@name, FakeBackend, self())
    DeploymentQueue.enqueue(tail_deployment.id, @name)
    DeploymentQueue.enqueue(head_deployment.id, @name)
    refute_receive {100, _}
    assert_receive {200, _}
  end
end
