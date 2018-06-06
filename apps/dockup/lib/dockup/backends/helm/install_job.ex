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

  def perform(project_identifier, repository, branch,
              callback \\ DefaultCallback.lambda, deps \\ []) do
    project    = deps[:project]    || Project

    project_id = to_string(project_identifier)

    callback.(:cloning_repo, nil)
    project.clone_repository(project_id, repository, branch)

    callback.(:starting, nil)
    # name = ?a..?z |> Enum.take_random(len) |> to_string
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

    callback.(:checking_urls, log_url(project_id))
    urls = project.wait_till_up([url], project_id)

    callback.(:started, urls)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, project_identifier, message)
      reraise(exception, stacktrace)
  end

  defp helm_run(dir, command) do
    Command.run("helm", command, dir)
  end

  # This should be something else! Maybe logging should be separate framework
  # We can use ELK and get logging out. K8s has out of box fluentd, not sure
  # what that is, it can be used for logging
  defp log_url(project_id) do
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    "logio.#{base_domain}/#?projectName=#{project_id}"
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured when deploying #{project_identifier} : #{message}"
    Logger.error message
    callback.(:deployment_failed, message)
  end
end
