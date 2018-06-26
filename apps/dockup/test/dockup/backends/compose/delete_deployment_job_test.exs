defmodule Dockup.Backends.Compose.DeleteDeploymentJobTest do
  use ExUnit.Case, async: true

  defmodule FakeProject do
    def delete_repository("123"), do: :ok
  end

  defmodule FakeContainer do
    def stop_containers("123"), do: send self(), :stopped_containers
  end

  defmodule FakeCallback do
    def update_status(deployment_id, event) do
      send self(), {deployment_id, event}
    end

    def set_urls(deployment_id, urls) do
      send self(), {:set_urls, deployment_id, urls}
    end

    def set_log_url(deployment_id, log_url) do
      send self(), {:set_log_url, deployment_id, log_url}
    end
  end

  test "performing the delete deployment job stops the project and deletes project dir" do
    Dockup.Backends.Compose.DeleteDeploymentJob.perform(123, FakeCallback, project: FakeProject, container: FakeContainer)
    assert_received :stopped_containers
    assert_received {123, "deleted"}
  end
end
