defmodule Dockup.Container do
  require Logger

  alias Dockup.{
    Project,
    DockerComposeConfig
  }

  def start_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Starting containers of project #{project_id}"
    command.run(
      "docker-compose",
      [
        "-f", "#{docker_compose_file(project_id)}",
        "-p", "#{project_id}",
        "up",
        "-d"
      ],
      Project.project_dir(project_id)
    )
  end

  def stop_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Stopping deployment-#{project_id} containers"
    command.run(
      "docker-compose",
      [
        "-f", "#{docker_compose_file(project_id)}",
        "-p", "#{project_id}",
        "down",
        "-v"
      ],
      Project.project_dir(project_id)
    )
  end

  defp docker_compose_file(project_id) do
    DockerComposeConfig.compose_file_name(project_id)
  end
end
