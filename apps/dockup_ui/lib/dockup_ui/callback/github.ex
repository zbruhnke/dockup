defmodule DockupUi.Callback.Github do
  alias DockupUi.{
    CallbackProtocol,
    CallbackProtocol.Defaults
  }

  require Logger

  defstruct [:repo_full_name, :deployment_id]

  defimpl CallbackProtocol, for: __MODULE__ do
    use Defaults

    def started(callback_data, deployment, _payload) do
      DockupUi.Callback.Github.update_deployment_status("success", deployment.id, callback_data.repo_full_name, callback_data.deployment_id)
    end

    def deployment_failed(callback_data, deployment, _payload) do
      DockupUi.Callback.Github.update_deployment_status("failure", deployment.id, callback_data.repo_full_name, callback_data.deployment_id)
    end
  end

  def create_github_deployment(pull_request) do
    repo_full_name = pull_request["head"]["repo"]["full_name"]
    url = "https://#{github_oauth_token()}@api.github.com/repos/#{repo_full_name}/deployments"

    request_body = Poison.encode! %{
      ref: pull_request["head"]["ref"],
      auto_merge: false,
      environment: "dockup",
      required_contexts: []
    }

    HTTPotion.post url, [
      body: request_body,
      headers: [
        "Content-Type": "application/json",
        "User-Agent": "Dockup"
      ]
    ]
  end

  def update_deployment_status(state, id, repo_full_name, deployment_id) do
    Logger.info "Updating state of deployment #{id} to #{state} in github"
    url = "https://#{github_oauth_token()}@api.github.com/repos/#{repo_full_name}/deployments/#{deployment_id}/statuses"
    deployment_url = DockupUi.Router.Helpers.deployment_url(DockupUi.Endpoint, :show, id)

    request_body = Poison.encode! %{
      state: state,
      target_url: deployment_url
    }

    HTTPotion.post url, [
      body: request_body,
      headers: [
        "Content-Type": "application/json",
        "User-Agent": "Dockup"
      ]
    ]
  end

  defp github_oauth_token() do
    System.get_env("DOCKUP_GITHUB_OAUTH_TOKEN") || Application.get_env(:dockup_ui, :github_oauth_token)
  end
end
