defmodule Dockup.DeployJobTest do
  use ExUnit.Case, async: true

  defmodule FakeProject do
    def clone_repository("123", "fake_repo", "fake_branch"), do: :ok
    def wait_till_up(["dummy_url"], "123"), do: ["dummy_url/path"]
  end

  defmodule FakeDockerComposeConfig do
    def rewrite_variables("123") do
      send self(), :docker_compose_config_prepared
      ["dummy_url"]
    end
  end

  defmodule FakeContainer do
    def start_containers("123"), do: send self(), :containers_started
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

  test "performing a deployment triggers deployment using the project type" do
    Dockup.Backends.Compose.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback,
                                              project: FakeProject, container: FakeContainer, docker_compose_config: FakeDockerComposeConfig)
    assert_received {123, "starting"}
    assert_received :docker_compose_config_prepared
    assert_received :containers_started

    assert_received {123, "waiting_for_urls"}
    assert_received {:set_log_url, 123, "logio.127.0.0.1.xip.io/#?projectName=123"}
    assert_received {123, "started"}
    assert_received {:set_urls, 123, ["dummy_url/path"]}
  end

  test "triggers deployment_failed callback when an exception occurs" do
    defmodule FakeFailingContainer do
      def start_containers("123") do
        raise "ifuckedup"
      end
    end

    assert_raise RuntimeError, "ifuckedup", fn ->
      Dockup.Backends.Compose.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback,
                                                project: FakeProject, container: FakeFailingContainer, docker_compose_config: FakeDockerComposeConfig)
    end

    assert_received {123, "failed"}
  end
end
