defmodule DockupUi.GithubWebhook do
  import Ecto.Query
  alias DockupUi.{
    Repo,
    Repository,
    Callback.Github,
    DeployService
  }

  def handle(conn, payload) when is_binary(payload) do
    conn = Plug.Conn.fetch_query_params(conn)

    do_handle(Poison.decode!(payload), conn.params)
  end

  defp do_handle(%{"pull_request" => pull_request, "action" => action}, %{"organization_id" => organization_id})
    when action in ["opened", "synchronize", "reopened"] do

    # Make sure a repo exists with the git url under the given org
    %Repository{} = get_repository(pull_request["head"]["repo"], organization_id)

    Github.create_github_deployment(pull_request)
  end

  defp do_handle(params = %{"deployment" => deployment}, %{"organization_id" => organization_id}) do
    organization_id = String.to_integer(organization_id)
    branch = deployment["ref"]

    callback_params = %{
      github_deployment_params: %{
        deployment_id: deployment["id"],
        repo_full_name: params["repository"]["full_name"]
      }
    }

    params["repository"]
    |> get_repository(organization_id)
    |> deploy_repository(branch, callback_params)

    :ok
  end

  defp do_handle(_, _) do
    :ok
  end

  defp deploy_repository(repository, branch, callback_params) do
    DeployService.run(repository, branch, callback_params, callback: Github)
  end

  defp get_repository(repo_params, organization_id) do
    urls = [
      repo_params["clone_url"],
      repo_params["ssh_url"]
    ]

    query =
      from r in Repository,
      where: r.git_url in ^urls,
      where: r.organization_id == ^organization_id,
      limit: 1

    Repo.one!(query)
  end
end
