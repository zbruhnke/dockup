defmodule Dockup.ContainerTest do
  use ExUnit.Case, async: true

  test "start_containers runs docker-compose up" do
    defmodule StartContainersCommand do
      def run("docker-compose", ["-p", "foo", "up", "-d"], dir) do
        # Ensure command is run inside project directory
        ^dir = Dockup.Project.project_dir("foo")
      end
    end
    Dockup.Container.start_containers("foo", StartContainersCommand)
  end

  test "stop_containers runs docker-compose down" do
    defmodule StopContainersCommand do
      def run("docker-compose", ["-p", "foo", "down", "-v"], dir) do
        # Ensure command is run inside project directory
        ^dir = Dockup.Project.project_dir("foo")
      end
    end
    Dockup.Container.stop_containers("foo", StopContainersCommand)
  end
end
