defmodule DockupUi.API.BitbucketWebhookControllerTest do
  use DockupUi.ConnCase
  import DockupUi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defmodule FakeDeleteDeploymentService do
    def run_all([1, 2]) do
      true
    end
  end

  test "pullrequest:rejected deletes all deployments with the git url and branch", %{conn: conn} do
    conn =
      conn
      |> put_req_header("x-event-key", "pullrequest:rejected")
      |> assign(:delete_deployment_service, FakeDeleteDeploymentService)

    branch = "mybranch"
    git_url = "git@bitbucket.org:foo/bar.git"

    insert(:deployment, git_url: git_url, branch: branch, id: 1)
    insert(:deployment, git_url: git_url, branch: branch, id: 2)
    insert(:deployment, git_url: git_url, branch: "different-branch", id: 3)

    params = %{
      pullrequest: %{source: %{branch: %{name: branch}}},
      repository: %{full_name: "foo/bar"}
    }

    conn = post conn, api_bitbucket_webhook_path(conn, :create, params)
    assert response(conn, 200) == "ok"
  end

  test "pullrequest:fulfilled deletes all deployments with the git url and branch", %{conn: conn} do
    conn =
      conn
      |> put_req_header("x-event-key", "pullrequest:fulfilled")
      |> assign(:delete_deployment_service, FakeDeleteDeploymentService)

    branch = "mybranch"
    git_url = "git@bitbucket.org:foo/bar.git"

    insert(:deployment, git_url: git_url, branch: branch, id: 1)
    insert(:deployment, git_url: git_url, branch: branch, id: 2)
    insert(:deployment, git_url: git_url, branch: "different-branch", id: 3)

    params = %{
      pullrequest: %{source: %{branch: %{name: branch}}},
      repository: %{full_name: "foo/bar"}
    }

    conn = post conn, api_bitbucket_webhook_path(conn, :create, params)
    assert response(conn, 200) == "ok"
  end
end

