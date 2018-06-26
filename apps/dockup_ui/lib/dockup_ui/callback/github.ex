defmodule DockupUi.Callback.Github do
  # This module is unusable at the moment, this can be used once
  # we have a schema for project and it is linked to a github repo.

  require Logger


  def create_github_deployment(pull_request) do
    repo_full_name = pull_request["head"]["repo"]["full_name"]
    url = "https://#{github_oauth_token()}@api.github.com/repos/#{repo_full_name}/deployments"

    request_body = Poison.encode! %{
      ref: pull_request["head"]["ref"],
      auto_merge: false,
      environment: "dockup",
      required_contexts: []
    }

    post_to_github(url, request_body)
  end

  def update_deployment_status(state, id, repo_full_name, deployment_id) do
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
    Task.async fn ->
      HTTPotion.post url, [
        body: request_body,
        headers: [
          "Content-Type": "application/json",
          "User-Agent": "Dockup"
        ]
      ]
    end
  end

  defp github_oauth_token() do
    System.get_env("DOCKUP_GITHUB_OAUTH_TOKEN") || Application.get_env(:dockup_ui, :github_oauth_token)
  end
end
