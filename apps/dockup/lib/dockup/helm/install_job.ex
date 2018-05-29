defmodule Dockup.Helm.InstallJob do
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
    dir = Project.project_dir(project_id)
    tag = "tag"
    command = ["install",
               "--set", "image.tag=#{tag}",
               "--name=#{name}",
               "helm"]

    case helm_run(dir, command) do
      {_, 0} -> "Success!"
      {out, _} -> raise out
    end

    domain = Application.fetch_env!(:dockup, :domain)
    urls = [name <> "." <> domain]
    callback.(:checking_urls, log_url(project_id))
    urls = project.wait_till_up(urls, project_id)

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
    domain = Application.fetch_env!(:dockup, :domain)
    "logio.#{domain}/#?projectName=#{project_id}"
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured when deploying #{project_identifier} : #{message}"
    Logger.error message
    callback.(:deployment_failed, message)
  end
end
