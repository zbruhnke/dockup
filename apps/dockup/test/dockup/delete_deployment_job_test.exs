defmodule Dockup.DeleteDeploymentJobTest do
  use ExUnit.Case, async: true

  defmodule FakeProject do
    def delete_repository("123"), do: :ok
    def stop("123"), do: :ok
  end

  defmodule FakeCallback do
    def lambda do
      fn(event, payload) ->
        send self, {event, payload}
      end
    end
  end

  test "performing the delete deployment job stops the project and deletes project dir" do
    Dockup.DeleteDeploymentJob.perform(123, FakeCallback.lambda, project: FakeProject)
    assert_received {:deleting_deployment, nil}
    assert_received {:deployment_deleted, nil}
  end

  test "triggers deployment_failed callback when an exception occurs" do
    defmodule FailingProject do
      def delete_repository("123"), do: :ok
      def stop("123") do
        raise "project could not stop"
      end
    end
    Dockup.DeleteDeploymentJob.perform(123, FakeCallback.lambda, project: FailingProject)
    assert_received {:deleting_deployment, nil}
    assert_received {:delete_deployment_failed, "An error occured when deleting deployment 123 : project could not stop"}
  end
end
