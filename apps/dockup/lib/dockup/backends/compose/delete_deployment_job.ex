defmodule Dockup.Backends.Compose.DeleteDeploymentJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Backends.Compose.Container,
    Project
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(deployment_id, callback \\ DefaultCallback, deps \\ []) do
    container = deps[:container] || Container
    project = deps[:project] || Project
    project_id = to_string(deployment_id)

    container.stop_containers(project_id)
    project.delete_repository(project_id)

    callback.update_status(deployment_id, "deleted")
  end
end

