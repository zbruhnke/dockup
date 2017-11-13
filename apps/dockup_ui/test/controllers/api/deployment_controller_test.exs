defmodule DockupUi.API.DeploymentControllerTest do
  use DockupUi.ConnCase
  import DockupUi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    deployment = insert(:deployment)
    conn = get conn, api_deployment_path(conn, :index)
    assert json_response(conn, 200)["data"] == [
      %{
        "id" => deployment.id,
        "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
        "updated_at" => DateTime.to_iso8601(deployment.updated_at),
        "branch" => deployment.branch,
        "git_url" => deployment.git_url,
        "status" => deployment.status,
        "log_url" => deployment.log_url,
        "urls" => deployment.urls
      }
    ]
  end

  test "shows chosen resource", %{conn: conn} do
    deployment = insert(:deployment)
    conn = get conn, api_deployment_path(conn, :show, deployment)
    assert json_response(conn, 200)["data"] == %{
      "id" => deployment.id,
      "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
      "updated_at" => DateTime.to_iso8601(deployment.updated_at),
      "git_url" => deployment.git_url,
      "branch" => deployment.branch,
      "status" => deployment.status,
      "log_url" => deployment.log_url,
      "urls" => deployment.urls
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, api_deployment_path(conn, :show, -1)
    end
  end

  test "create renders resource when DeployService runs fine", %{conn: conn} do
    deployment = insert(:deployment, %{id: 1})

    defmodule FakeDeployService do
      def run(%{"foo" => "bar"}, %DockupUi.Callback.Web{callback_url: "callback_url"}) do
        {:ok, Repo.get(DockupUi.Deployment, 1)}
      end
    end

    conn = conn |> assign(:deploy_service, FakeDeployService)
    conn = post conn, api_deployment_path(conn, :create), %{"foo" => "bar", "callback_url" => "callback_url"}
    assert json_response(conn, 201)["data"]["id"] == deployment.id
  end

  test "create renders errors on model when DeployService fails", %{conn: conn} do
    defmodule FakeFailingDeployService do
      def run(%{}, _callback_data) do
        {:error, DockupUi.Deployment.create_changeset(%DockupUi.Deployment{}, %{})}
      end
    end

    conn = conn |> assign(:deploy_service, FakeFailingDeployService)
    conn = post conn, api_deployment_path(conn, :create), deployment: %{}
    assert json_response(conn, 422)["errors"] == %{
      "branch" => ["can't be blank"],
      "git_url" => ["can't be blank"]
    }
  end
end
