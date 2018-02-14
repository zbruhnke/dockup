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
    def lambda do
      fn(event, payload) ->
        send self(), {event, payload}
      end
    end
  end

  test "performing a deployment triggers deployment using the project type" do
    Dockup.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback.lambda,
                             project: FakeProject, container: FakeContainer, docker_compose_config: FakeDockerComposeConfig)
    assert_received {:cloning_repo, nil}
    assert_received {:starting, nil}
    assert_received :docker_compose_config_prepared
    assert_received :containers_started
    assert_received {:checking_urls, "logio.127.0.0.1.xip.io/#?projectName=123"}
    assert_received {:started, ["dummy_url/path"]}
  end

  test "triggers deployment_failed callback when an exception occurs" do
    defmodule FakeFailingContainer do
      def start_containers("123") do
        raise "ifuckedup"
      end
    end

    assert_raise RuntimeError, "ifuckedup", fn ->
      Dockup.DeployJob.perform(123, "fake_repo", "fake_branch", FakeCallback.lambda,
                              project: FakeProject, container: FakeFailingContainer, docker_compose_config: FakeDockerComposeConfig)
    end

    assert_received {:deployment_failed, "An error occured when deploying 123 : ifuckedup"}
  end
end
