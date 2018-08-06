defmodule DockupUi.API.DeploymentControllerTest do
  use DockupUi.ConnCase
  import DockupUi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    blueprint = insert(:blueprint)
    deployment = insert(:deployment, %{}, %{blueprint_id: blueprint.id})

    conn = get conn, api_deployment_path(conn, :index)
    assert json_response(conn, 200)["data"] == [
      %{
        "id" => deployment.id,
        "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
        "updated_at" => DateTime.to_iso8601(deployment.updated_at),
        "name" => deployment.name,
        "blueprint_name" => blueprint.name,
        "deployed_at" => nil,
        "status" => "pending"
      }
    ]
  end

  test "shows chosen resource", %{conn: conn} do
    blueprint = insert(:blueprint)
    deployment = insert(:deployment, %{}, %{blueprint_id: blueprint.id})

    conn = get conn, api_deployment_path(conn, :show, deployment)
    assert json_response(conn, 200)["data"] == %{
      "id" => deployment.id,
      "inserted_at" => DateTime.to_iso8601(deployment.inserted_at),
      "updated_at" => DateTime.to_iso8601(deployment.updated_at),
      "name" => deployment.name,
      "blueprint_name" => blueprint.name,
      "deployed_at" => nil,
      "status" => "pending"
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, api_deployment_path(conn, :show, -1)
    end
  end

  test "create renders resource when DeployService runs fine", %{conn: conn} do
    blueprint = insert(:blueprint)
    deployment = insert(:deployment, %{}, %{blueprint_id: blueprint.id, id: 1})

    defmodule FakeDeployService do
      def run(%{"foo" => "bar"}) do
        {:ok, %{deployment: Repo.get(DockupUi.Deployment, 1)}}
      end
    end

    conn = conn |> assign(:deploy_service, FakeDeployService)
    conn = post conn, api_deployment_path(conn, :create), %{"containerSpecs" => %{"foo" => "bar"}}
    assert json_response(conn, 201)["id"] == deployment.id
  end

  test "create renders errors on model when DeployService fails", %{conn: conn} do
    defmodule FakeFailingDeployService do
      def run(%{}) do
        {:error, :deployment, DockupUi.Deployment.changeset(%DockupUi.Deployment{}, %{}), nil}
      end
    end

    conn = conn |> assign(:deploy_service, FakeFailingDeployService)
    conn = post conn, api_deployment_path(conn, :create), containerSpecs: %{}
    assert json_response(conn, 422)["errors"] == %{
      "blueprint_id" => ["can't be blank"],
      "name" => ["can't be blank"],
      "status" => ["can't be blank"]
    }
  end
end
