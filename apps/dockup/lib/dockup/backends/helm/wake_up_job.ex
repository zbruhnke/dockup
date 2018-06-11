defmodule Dockup.Backends.Helm.WakeUpJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Command
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(project_identifier, callback \\ DefaultCallback.lambda) do
    callback.(:waking_up_deployment, nil)

    project_id = to_string(project_identifier)
    name = "dockup#{project_id}"
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    url = name <> "." <> base_domain

    {deploys, 0} =
      Command.run("kubectl",
        ["get", "deploy", "-l", "release=#{name}", "-o", "name"],
        ".")

    Enum.map(String.split(deploys, "\n"), &wake_up_deploy/1)

    callback.(:checking_urls, log_url(project_id))
    urls = Project.wait_till_up([url], project_id)

    callback.(:started, urls)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, project_identifier, message)
      reraise(exception, stacktrace)
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured while waking up deployment #{project_identifier} : #{message}"
    Logger.error message
    callback.(:deployment_failed, message)
  end

  # This should be something else! Maybe logging should be separate framework
  # We can use ELK and get logging out. K8s has out of box fluentd, not sure
  # what that is, it can be used for logging
  defp log_url(project_id) do
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    "logio.#{base_domain}/#?projectName=#{project_id}"
  end

  defp wake_up_deploy(deploy) do
    Dockup.Command.run("kubectl",
      ["patch", deploy, "-p", "{\"spec\":{\"replicas\":1}}"],
      ".")
  end
end
