defmodule Dockup.ContainerTest do
  use ExUnit.Case, async: true

  test "check_docker_version raises exception if docker version is incompatible" do
    defmodule OldDockerVersionCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.7", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.4", 0}
        end
      end
    end

    try do
      Dockup.Container.check_docker_version(OldDockerVersionCommand)
    rescue
      exception -> assert exception.message == "Docker version should be >= 1.8"
    end
  end

  test "check_docker_version raises exception if docker-compose version is incompatible" do
    defmodule OldDockerComposeVersionCommand do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.8", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.3", 0}
        end
      end
    end

    try do
      Dockup.Container.check_docker_version(OldDockerComposeVersionCommand)
    rescue
      exception -> assert exception.message == "docker-compose version should be >= 1.4"
    end
  end

  test "check_docker_version does not raise any exception if versions are compatible" do
    defmodule MatchingDockerVersion do
      def run(cmd, args) do
        case {cmd, args} do
          {"docker", ["-v"]} -> {"Docker version 1.8", 0}
          {"docker-compose",  ["-v"]} -> {"docker-compose version 1.4", 0}
        end
      end
    end

    Dockup.Container.check_docker_version(MatchingDockerVersion)
  end

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
