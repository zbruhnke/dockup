defmodule Dockup.Backends.Helm.HibernateJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Command
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(project_identifier, callback \\ DefaultCallback.lambda) do
    callback.(:hibernating_deployment, nil)

    project_id = to_string(project_identifier)
    name = "dockup#{project_id}"

    {deploys, 0} =
      Command.run("kubectl",
        ["get", "deploy", "-l", "release=#{name}", "-o", "name"],
        ".")

    Enum.map(String.split(deploys, "\n"), &hibernate_deploy/1)
    callback.(:deployment_hibernated, nil)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, project_identifier, message)
      reraise(exception, stacktrace)
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured while hibernating deployment #{project_identifier} : #{message}"
    Logger.error message
    callback.(:hibernate_deployment_failed, message)
  end

  defp hibernate_deploy(deploy) do
    Dockup.Command.run("kubectl",
      ["patch", deploy, "-p", "{\"spec\":{\"replicas\":0}}"],
      ".")
  end
end
