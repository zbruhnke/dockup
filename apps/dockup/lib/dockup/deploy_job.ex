defmodule Dockup.DeployJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Container,
    DockerComposeConfig
  }

  def spawn_process(%{id: id, git_url: repository, branch: branch}, callback) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch,
              callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:queued, nil)
    project    = deps[:project]    || Project
    container = deps[:container] || Container
    docker_compose_config = deps[:docker_compose_config] || DockerComposeConfig

    project_id = to_string(project_identifier)

    callback.(:cloning_repo, nil)
    project.clone_repository(project_id, repository, branch)

    callback.(:starting, nil)
    urls = docker_compose_config.rewrite_variables(project_id)
    container.start_containers(project_id)

    callback.(:checking_urls, log_url(project_id))
    project.wait_till_up(urls)

    callback.(:started, urls)
  rescue
    exception ->
      stacktrace = System.stacktrace
      message = Exception.message(exception)
      handle_error_message(callback, project_identifier, message)
      reraise(exception, stacktrace)
  end

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
