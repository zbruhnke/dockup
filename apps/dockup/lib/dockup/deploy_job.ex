defmodule Dockup.DeployJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Container,
    DockerComposeConfig
  }

  def spawn_process(%{id: id, branch: branch, repository: %{git_url: git_url}}, callback) do
    spawn(fn -> perform(id, git_url, branch, callback) end)
  end

  def perform(project_identifier, git_url, branch,
              callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:queued, nil)
    project    = deps[:project]    || Project
    container = deps[:container] || Container
    docker_compose_config = deps[:docker_compose_config] || DockerComposeConfig

    project_id = to_string(project_identifier)

    callback.(:cloning_repo, nil)
    project.clone_repository(project_id, git_url, branch)

    callback.(:starting, nil)
    urls = docker_compose_config.rewrite_variables(project_id)
    container.start_containers(project_id)

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
