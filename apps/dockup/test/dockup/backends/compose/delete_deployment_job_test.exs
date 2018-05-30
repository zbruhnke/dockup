defmodule Dockup.Backends.Compose.DeleteDeploymentJobTest do
  use ExUnit.Case, async: true

  defmodule FakeProject do
    def delete_repository("123"), do: :ok
  end

  defmodule FakeContainer do
    def stop_containers("123"), do: :ok
  end

  defmodule FakeCallback do
    def lambda do
      fn(event, payload) ->
        send self(), {event, payload}
      end
    end
  end

  test "performing the delete deployment job stops the project and deletes project dir" do
    Dockup.Backends.Compose.DeleteDeploymentJob.perform(123, FakeCallback.lambda, project: FakeProject, container: FakeContainer)
    assert_received {:deleting_deployment, nil}
    assert_received {:deployment_deleted, nil}
  end

  test "triggers delete_deployment_failed callback when an exception occurs" do
    defmodule FailingContainer do
      def stop_containers("123") do
        raise "cannot stop containers"
      end
    end

    assert_raise RuntimeError, "cannot stop containers", fn ->
      Dockup.Backends.Compose.DeleteDeploymentJob.perform(123, FakeCallback.lambda, project: FakeProject, container: FailingContainer)
    end

    assert_received {:deleting_deployment, nil}
    assert_received {:delete_deployment_failed, "An error occured when deleting deployment 123 : cannot stop containers"}
  end
end
