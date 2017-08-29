defmodule Dockup.ProjectTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  test "project_dir of a project is <Dockup workdir>/clones/<project_id>" do
    workdir = Application.fetch_env!(:dockup, :workdir)
    assert Dockup.Project.project_dir("foo") == "#{workdir}/clones/foo"
  end

  # Remove mocking in favor of dependency injection and make this test pass
  test "clone_repository clones the given branch of git repository into project_dir" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"
    project_dir = Dockup.Project.project_dir("foo")

    defmodule GitCloneCommand do
      def run(cmd, args) do
        send self(), {cmd, args}
        {"", 0}
      end
    end
    Dockup.Project.clone_repository("foo", repository, branch, GitCloneCommand)
    [cmd | args] = String.split("git clone --branch=master --depth=1 #{repository} #{project_dir}")

    receive do
      {command, arguments} ->
        assert command == cmd
        assert arguments == args
    end
  end

  # Remove mocking in favor of dependency injection and make this test pass
  test "clone_repository raises an exception when clone command fails" do
    repository = "https://github.com/code-mancers/dockup.git"
    branch = "master"

    defmodule FailingGitCloneCommand do
      def run(_cmd, _args) do
        {"cannot clone this shitz", 1}
      end
    end
    try do
      Dockup.Project.clone_repository("foo", repository, branch, FailingGitCloneCommand)
    rescue
      error ->
        assert error.message == "Cannot clone #{branch} of #{repository}. Error: cannot clone this shitz"
    end
  end

  test "wait_till_up waits until http response of url is 200" do
    Agent.start_link(fn -> 1 end, name: RetryCount)
    defmodule FakeHttp do
      def get_status("dummy_url") do
        count = Agent.get(RetryCount, fn count -> count end)
        Agent.update(RetryCount, fn count -> count + 1 end)
        if count == 3, do: 200, else: 404
      end
    end

    urls = ["dummy_url"]
    logs = capture_log(fn -> Dockup.Project.wait_till_up(urls, FakeHttp, 0) end)
    assert logs =~ "Attempt 1 failed"
    assert logs =~ "Attempt 2 failed"
    refute logs =~ "Attempt 3 failed"

    Agent.stop(RetryCount)
  end
end
