defmodule DockupUi.DeploymentControllerTest do
  use DockupUi.ConnCase

  setup do
    conn = build_conn() |> assign(:current_user, "foo")
    {:ok, conn: conn}
  end

  test "GET /deploy", %{conn: conn} do
    conn = get(conn, "/deploy")
    assert html_response(conn, 200) =~ "deployment_form_container"
  end

  test "GET /deployments", %{conn: conn} do
    conn = get conn, "/deployments"
    assert html_response(conn, 200) =~ "deployments_list_container"
  end
end
