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

  def perform(deployment_id, callback \\ DefaultCallback) do
    callback.update_status(deployment_id, "waking_up")

    project_id = to_string(deployment_id)
    name = "dockup#{project_id}"
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    url = name <> "." <> base_domain

    {deploys, 0} =
      Command.run("kubectl",
        ["get", "deploy", "-l", "release=#{name}", "-o", "name"],
        ".")

    deploys
    |> String.split("\n")
    |> Enum.map(&wake_up_deploy/1)

    callback.update_status(deployment_id, "waiting_for_urls")
    callback.set_log_url(deployment_id, log_url(project_id))
    urls = Project.wait_till_up([url], project_id)

    callback.update_status(deployment_id, "started")
    callback.set_urls(deployment_id, urls)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, deployment_id, message)
      reraise(exception, stacktrace)
  end

  defp handle_error_message(callback, deployment_id, message) do
    message = "An error occured while waking up deployment #{deployment_id} : #{message}"
    Logger.error message
    callback.update_status(deployment_id, "failed")
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
