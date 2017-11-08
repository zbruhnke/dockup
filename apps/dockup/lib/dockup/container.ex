defmodule Dockup.Container do
  require Logger

  def start_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Starting containers of project #{project_id}"
    command.run("docker-compose", ["-p", "#{project_id}", "up", "-d"], Dockup.Project.project_dir(project_id))
  end

  def stop_containers(project_id, command \\ Dockup.Command) do
    Logger.info "Stopping deployment-#{project_id} containers"
    command.run("docker-compose", ["-p", "#{project_id}", "down", "-v"], Dockup.Project.project_dir(project_id))
  end
end
