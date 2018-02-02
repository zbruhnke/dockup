defmodule DockupUi.Callback.Github do

  require Logger

  def lambda(callback_params, default_callback \\ DockupUi.Callback) do
    fn
      event, payload ->
        update_status(event, callback_params.deployment, callback_params.github_deployment_params)
        default_callback.lambda(callback_params).(event, payload)
    end
  end

  def update_status(:started, deployment, github_deployment_params) do
    update_deployment_status("success", deployment.id, github_deployment_params.repo_full_name, github_deployment_params.deployment_id)
  end

  def update_status(:deployment_failed, deployment, github_deployment_params) do
    update_deployment_status("failure", deployment.id, github_deployment_params.repo_full_name, github_deployment_params.deployment_id)
  end

  def update_status(_status, _deployment, _github_deployment_params) do
    :ok
  end

  def create_github_deployment(pull_request) do
    repo_full_name = pull_request["head"]["repo"]["full_name"]
    url = "https://#{github_oauth_token()}@api.github.com/repos/#{repo_full_name}/deployments"

    request_body = Poison.encode! %{
      ref: pull_request["head"]["ref"],
      auto_merge: false,
      environment: "dockup"
    }

    post_to_github(url, request_body)
  end

  defp update_deployment_status(state, id, repo_full_name, deployment_id) do
    Logger.info "Updating state of deployment #{id} to #{state} in github"
    url = "https://#{github_oauth_token()}@api.github.com/repos/#{repo_full_name}/deployments/#{deployment_id}/statuses"

    deployment_url =
      if is_nil(id) do
        nil
      else
        DockupUi.Router.Helpers.deployment_url(DockupUi.Endpoint, :show, id)
      end

    request_body = Poison.encode! %{
      state: state,
      target_url: deployment_url
    }

    post_to_github(url, request_body)
  end

  defp post_to_github(url, request_body) do
    Task.start fn ->
      HTTPotion.post(url, [
        body: request_body,
        headers: [
          "Content-Type": "application/json",
          "User-Agent": "Dockup"
        ]
      ])
    end
  end

  #TODO: This should be set as a config per organization
  # or better yet, use github integrations to toggle
  # webhooks per repository.
  defp github_oauth_token() do
    Application.get_env(:dockup_ui, :github_oauth_token)
  end
end
