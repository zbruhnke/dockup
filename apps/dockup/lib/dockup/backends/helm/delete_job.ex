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
    IO.inspect project_identifier
    callback.(:deleting_deployment, nil)

    project = deps[:project] || Project
    project_id = to_string(project_identifier)
    name = "dockup#{project_id}"

    {_, 0} = Command.run("helm", ["delete", name], ".")
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
