defmodule Dockup.DeleteDeploymentJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(project_identifier, callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:deleting_deployment, nil)

    project    = deps[:project]    || Project
    project_id = to_string(project_identifier)

    project.stop(project_id)
    project.delete_repository(project_id)

    callback.(:deployment_deleted, nil)
  rescue
    error in MatchError ->
      handle_error_message(callback, project_identifier, (inspect error))
    e ->
      handle_error_message(callback, project_identifier, e.message)
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured when deleting deployment #{project_identifier} : #{message}"
    Logger.error message
    callback.(:delete_deployment_failed, message)
  end
end

