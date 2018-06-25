defmodule Dockup.Backends.Helm.InstallJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Command
  }

  def spawn_process(%{id: id, git_url: repository, branch: branch}, callback) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(deployment_id, repository, branch,
              callback \\ DefaultCallback, deps \\ []) do
    project    = deps[:project]    || Project

    project_id = to_string(deployment_id)

    project.clone_repository(project_id, repository, branch)

    name = "dockup#{project_id}"
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    url = name <> "." <> base_domain
    dir = Project.project_dir(project_id)
    {git_sha1, 0} = Command.run("git", ["rev-parse", "HEAD"], dir)
    tag = String.trim(git_sha1)
    command = ["install",
               "--set", "image.tag=#{tag}",
               "--set", "ingress.hosts[0]=#{url}",
               "--name=#{name}",
               "helm"]

    case helm_run(dir, command) do
      {_, 0} -> "Success!"
      {out, _} -> raise out
    end

    callback.update_status(deployment_id, "waiting_for_urls")
    callback.set_log_url(deployment_id, log_url(name))
    urls = project.wait_till_up([url], project_id)

    callback.update_status(deployment_id, "started")
    callback.set_urls(deployment_id, urls)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, deployment_id, message)
      reraise(exception, stacktrace)
  end

  defp helm_run(dir, command) do
    Command.run("helm", command, dir)
  end

  # This should be something else! Maybe logging should be separate framework
  # We can use ELK and get logging out. K8s has out of box fluentd, not sure
  # what that is, it can be used for logging
  defp log_url(name) do
    base_url = Application.fetch_env!(:dockup, :stackdriver_url)
    filter = "advancedFilter=&filters=text:#{name}"
    base_url <> "&" <> filter
  end

  defp handle_error_message(callback, deployment_id, message) do
    message = "An error occured when deploying #{deployment_id} : #{message}"
    Logger.error message
    callback.update_status(deployment_id, "failed")
  end
end
