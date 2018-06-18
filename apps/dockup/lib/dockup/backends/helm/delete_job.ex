defmodule Dockup.Backends.Helm.DeleteJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Command
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(project_identifier, callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:deleting_deployment, nil)

    project = deps[:project] || Project
    project_id = to_string(project_identifier)
    name = "dockup#{project_id}"

    case Command.run("helm", ["delete", name], ".") do
      {_, 0} ->
        Logger.info("deleted #{name} successfully")
      {error_msg, 1} ->
        msg = "Error: release: \"#{name}\" not found"
        if error_msg == msg do
          Logger.info("helm: #{name} not found, its okay")
        else
          Logger.info(error_msg)
        end
    end
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
