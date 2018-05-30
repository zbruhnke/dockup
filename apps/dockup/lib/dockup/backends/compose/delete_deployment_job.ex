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

  def perform(project_identifier, callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:deleting_deployment, nil)

    container = deps[:container] || Container
    project = deps[:project] || Project
    project_id = to_string(project_identifier)

    container.stop_containers(project_id)
    project.delete_repository(project_id)

    callback.(:deployment_deleted, nil)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, project_identifier, message)
      reraise(exception, stacktrace)
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured when deleting deployment #{project_identifier} : #{message}"
    Logger.error message
    callback.(:delete_deployment_failed, message)
  end
end

