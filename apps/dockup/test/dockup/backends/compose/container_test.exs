defmodule Dockup.Backends.Compose.ContainerTest do
  use ExUnit.Case, async: true

  test "start_containers runs docker-compose up" do
    defmodule StartContainersCommand do
      def run("docker-compose", ["-f", "my-docker-compose.yml", "pull"], dir) do
        # Ensure command is run inside project directory
        ^dir = Dockup.Project.project_dir("foo")
      end

      def run("docker-compose", ["-f", "my-docker-compose.yml", "-p", "foo", "up", "--build", "-d"], dir) do
        # Ensure command is run inside project directory
        ^dir = Dockup.Project.project_dir("foo")
      end
    end

    File.rm_rf Dockup.Project.project_dir("foo")
    File.mkdir_p! Dockup.Project.project_dir("foo")
    config_file = Dockup.Project.config_file("foo")
    file_content = """
    {
      "docker_compose_file": "my-docker-compose.yml"
    }
    """
    File.write!(config_file, file_content)

    Dockup.Backends.Compose.Container.start_containers("foo", StartContainersCommand)
  end

  test "stop_containers runs docker-compose down" do
    defmodule StopContainersCommand do
      def run("docker-compose", ["-f", "docker-compose.yml", "-p", "foo", "down", "-v"], dir) do
        # Ensure command is run inside project directory
        ^dir = Dockup.Project.project_dir("foo")
      end
    end

    File.rm_rf Dockup.Project.project_dir("foo")
    Dockup.Backends.Compose.Container.stop_containers("foo", StopContainersCommand)
  end
end
