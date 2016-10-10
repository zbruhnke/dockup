defmodule DockupUi.DeploymentControllerTest do
  use DockupUi.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "deployment_form_container"
  end

  test "GET /deployments", %{conn: conn} do
    conn = get conn, "/deployments"
    assert html_response(conn, 200) =~ "deployments_list_container"
  end
end
