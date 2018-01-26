defmodule DockupUi.API.DeploymentControllerTest do
  use DockupUi.ConnCase
  import DockupUi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup %{conn: conn} do
    user = insert(:user)
    organization = insert(:organization)
    repository = insert(:repository, organization_id: organization.id)
    DockupUi.AssignUserOrganizationService.assign_user(organization, user.email)

    conn =
      conn
      |> assign(:current_user, user)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, repository: repository}
  end

  test "lists all entries on index", %{conn: conn, repository: repository} do
    deployment = insert(:deployment, repository_id: repository.id)

    conn = get conn, api_deployment_path(conn, :index)
    assert json_response(conn, 200)["data"] == [
      %{
        "id" => deployment.id,
        "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
        "updated_at" => DateTime.to_iso8601(deployment.updated_at),
        "branch" => deployment.branch,
        "status" => deployment.status,
        "log_url" => deployment.log_url,
        "urls" => deployment.urls,
        "repository_id" => repository.id,
        "repository_url" => repository.git_url
      }
    ]
  end

  test "shows chosen resource", %{conn: conn, repository: repository} do
    deployment = insert(:deployment, repository_id: repository.id)
    conn = get conn, api_deployment_path(conn, :show, deployment)
    assert json_response(conn, 200)["data"] == %{
      "id" => deployment.id,
      "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
      "updated_at" => DateTime.to_iso8601(deployment.updated_at),
      "branch" => deployment.branch,
      "status" => deployment.status,
      "log_url" => deployment.log_url,
      "urls" => deployment.urls,
      "repository_id" => repository.id,
      "repository_url" => repository.git_url
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, api_deployment_path(conn, :show, -1)
    end
  end

  test "create renders resource when DeployService runs fine", %{conn: conn, repository: repository} do
    deployment = insert(:deployment, %{id: 1, repository_id: repository.id})

    defmodule FakeDeployService do
      def run(%DockupUi.Repository{git_url: _}, "bar") do
        {:ok, Repo.get(DockupUi.Deployment, 1)}
      end
    end

    conn = conn |> assign(:deploy_service, FakeDeployService)
    conn = post conn, api_deployment_path(conn, :create), %{"git_url" => repository.git_url, "branch" => "bar"}
    assert json_response(conn, 201)["data"]["id"] == deployment.id
  end

  test "create renders errors on model when DeployService fails", %{conn: conn, repository: repository} do
    defmodule FakeFailingDeployService do
      def run(repository, nil) do
        {:error, DockupUi.Deployment.create_changeset(%DockupUi.Deployment{}, %{repository_id: repository.id, branch: nil})}
      end
    end

    conn = conn |> assign(:deploy_service, FakeFailingDeployService)
    conn = post conn, api_deployment_path(conn, :create), %{git_url: repository.git_url, branch: nil}
    assert json_response(conn, 422)["errors"] == %{
      "branch" => ["can't be blank"]
    }
  end
end
