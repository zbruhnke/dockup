defmodule Dockup.Container do
  require Logger

  def check_docker_version(command \\ Dockup.Command) do
    {docker_version, 0} = command.run("docker", ["-v"])
    unless Regex.match?(~r/Docker version 1\.([8-9]|([0-9][0-9]))(.*)+/, docker_version) do
      raise "Docker version should be >= 1.8"
    end

    {docker_compose_version, 0} = command.run("docker-compose", ["-v"])
    unless Regex.match?(~r/docker-compose version.* 1\.([4-9]|([0-9][0-9]))(.*)+/, docker_compose_version) do
      raise "docker-compose version should be >= 1.4"
    end
  end

  def start_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Starting containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "up", "-d"], Dockup.Project.project_dir(project_id))
  end

  def stop_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Stopping deployment-#{project_id} containers"
    command.run("docker-compose", ["-p", "#{project_id}", "down", "-v"], Dockup.Project.project_dir(project_id))
  end
end
