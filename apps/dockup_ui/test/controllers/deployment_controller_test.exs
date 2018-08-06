defmodule DockupUi.DeploymentControllerTest do
  use DockupUi.ConnCase

  alias DockupUi.{
    Blueprint,
    ContainerSpec
  }

  setup do
    conn = build_conn() |> assign(:current_user, "foo")
    {:ok, conn: conn}
  end

  test "GET /deploy", %{conn: conn} do
    b = Blueprint.changeset(%Blueprint{}, %{name: "k8s-test"}) |> Repo.insert!
    ContainerSpec.changeset(%ContainerSpec{blueprint_id: b.id}, %{name: "frontend", image: "image", default_tag: "master"}) |> Repo.insert!

    conn = get(conn, "/deploy")
    assert html_response(conn, 200) =~ "deployment_form_container"
  end

  test "GET /deployments", %{conn: conn} do
    conn = get conn, "/deployments"
    assert html_response(conn, 200) =~ "deployments_list_container"
  end
end
