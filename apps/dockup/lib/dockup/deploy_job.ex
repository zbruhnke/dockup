defmodule Dockup.DeployJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
  }

  def spawn_process(%{id: id, git_url: repository, branch: branch}, callback) do
    spawn(fn -> perform(id, repository, branch, callback) end)
  end

  def perform(project_identifier, repository, branch,
              callback \\ DefaultCallback.lambda, deps \\ []) do
    callback.(:queued, nil)
    project    = deps[:project]    || Project
    deploy_job = deps[:deploy_job] || __MODULE__

    project_id = to_string(project_identifier)

    callback.(:cloning_repo, nil)
    project.clone_repository(project_id, repository, branch)

    project_type = project.project_type(project_id)
    callback.(:starting, log_url(project_id))
    urls = deploy_job.deploy(project_type, project_id)

    callback.(:checking_urls, nil)
    project.wait_till_up(urls)

    callback.(:started, urls)
  rescue
    error in MatchError ->
      handle_error_message(callback, project_identifier, (inspect error))
    e ->
      handle_error_message(callback, project_identifier, e.message)
  end

  @doc """
  Given a project type and project id, deploys the app and
  and returns a list : [{<port>, <http://ip_on_docker:port>, <service_url>} ...]
  """
  def deploy(type, project_id, config_generator \\ Dockup.ConfigGenerator, project \\ Dockup.Project)

  def deploy(:unknown, project_id, _config_generator, project) do
    Logger.info "Deploying #{project_id} using custom configuration"
    project.start(project_id)
  end

  def deploy(type, project_id, config_generator, project) do
    Logger.info "Deploying #{type} #{project_id}"
    config_generator.generate(type, project_id)
    project.start(project_id)
  end

  defp log_url(project_id) do
    "/deployment_logs/#?projectName=#{project_id}"
  end

  defp handle_error_message(callback, project_identifier, message) do
    message = "An error occured when deploying #{project_identifier} : #{message}"
    Logger.error message
    callback.(:deployment_failed, message)
  end
end
