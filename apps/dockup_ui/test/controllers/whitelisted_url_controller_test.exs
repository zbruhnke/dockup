defmodule DockupUi.WhitelistedUrlControllerTest do
  use DockupUi.ConnCase

  alias DockupUi.WhitelistedUrl
  @valid_attrs %{git_url: "some git_url"}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, whitelisted_url_path(conn, :new)
    assert html_response(conn, 200) =~ "New whitelisted url"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, whitelisted_url_path(conn, :create), whitelisted_url: @valid_attrs
    assert redirected_to(conn) == whitelisted_url_path(conn, :new)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, whitelisted_url_path(conn, :create), whitelisted_url: @invalid_attrs
    assert html_response(conn, 200) =~ "New whitelisted url"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{}
    conn = get conn, whitelisted_url_path(conn, :edit, whitelisted_url)
    assert html_response(conn, 200) =~ "Edit whitelisted url"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{}
    conn = put conn, whitelisted_url_path(conn, :update, whitelisted_url), whitelisted_url: @valid_attrs
    assert redirected_to(conn) == config_path(conn, :index)
    assert Repo.get_by(WhitelistedUrl, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{}
    conn = put conn, whitelisted_url_path(conn, :update, whitelisted_url), whitelisted_url: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit whitelisted url"
  end

  test "deletes chosen resource", %{conn: conn} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{}
    conn = delete conn, whitelisted_url_path(conn, :delete, whitelisted_url)
    assert redirected_to(conn) == config_path(conn, :index)
    refute Repo.get(WhitelistedUrl, whitelisted_url.id)
  end
end
