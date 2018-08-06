defmodule DockupUi.SubdomainControllerTest do
  use DockupUi.ConnCase

  alias DockupUi.Subdomain
  @invalid_attrs %{}

  setup do
    conn = build_conn() |> assign(:current_user, "foo")
    {:ok, conn: conn}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, subdomain_path(conn, :new)
    assert html_response(conn, 200) =~ "New Subdomain"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, subdomain_path(conn, :create), subdomain: @invalid_attrs
    assert html_response(conn, 200) =~ "New Subdomain"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    subdomain = Repo.insert! %Subdomain{}
    conn = get conn, subdomain_path(conn, :edit, subdomain)
    assert html_response(conn, 200) =~ "Edit Subdomain"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    subdomain = Repo.insert! %Subdomain{}
    conn = put conn, subdomain_path(conn, :update, subdomain), subdomain: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Subdomain"
  end

  test "deletes chosen resource", %{conn: conn} do
    subdomain = Repo.insert! %Subdomain{}
    conn = delete conn, subdomain_path(conn, :delete, subdomain)
    assert redirected_to(conn) == config_path(conn, :index)
    refute Repo.get(Subdomain, subdomain.id)
  end
end
