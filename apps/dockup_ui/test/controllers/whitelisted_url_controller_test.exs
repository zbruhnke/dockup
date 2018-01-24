defmodule DockupUi.WhitelistedUrlControllerTest do
  use DockupUi.ConnCase

  import DockupUi.Factory

  alias DockupUi.WhitelistedUrl
  @valid_attrs %{git_url: "some git_url"}
  @invalid_attrs %{}

  setup do
    user = insert(:user)
    organization = insert(:organization)
    DockupUi.AssignUserOrganizationService.assign_user(organization, user.email)

    conn = build_conn() |> assign(:current_user, user)
    {:ok, conn: conn, organization: organization}
  end

  test "renders form for new resources", %{conn: conn, organization: organization} do
    conn = get conn, organization_whitelisted_url_path(conn, :new, organization)
    assert html_response(conn, 200) =~ "New whitelisted url"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, organization: organization} do
    conn = post conn, organization_whitelisted_url_path(conn, :create, organization), whitelisted_url: @valid_attrs
    assert redirected_to(conn) == organization_whitelisted_url_path(conn, :new, organization)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    conn = post conn, organization_whitelisted_url_path(conn, :create, organization), whitelisted_url: @invalid_attrs
    assert html_response(conn, 200) =~ "New whitelisted url"
  end

  test "renders form for editing chosen resource", %{conn: conn, organization: organization} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{organization_id: organization.id}
    conn = get conn, organization_whitelisted_url_path(conn, :edit, organization, whitelisted_url)
    assert html_response(conn, 200) =~ "Edit whitelisted url"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, organization: organization} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{organization_id: organization.id}
    conn = put conn, organization_whitelisted_url_path(conn, :update, organization, whitelisted_url), whitelisted_url: @valid_attrs
    assert redirected_to(conn) == organization_config_path(conn, :index, organization)
    assert Repo.get_by(WhitelistedUrl, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{organization_id: organization.id}
    conn = put conn, organization_whitelisted_url_path(conn, :update, organization, whitelisted_url), whitelisted_url: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit whitelisted url"
  end

  test "deletes chosen resource", %{conn: conn, organization: organization} do
    whitelisted_url = Repo.insert! %WhitelistedUrl{organization_id: organization.id}
    conn = delete conn, organization_whitelisted_url_path(conn, :delete, organization, whitelisted_url)
    assert redirected_to(conn) == organization_config_path(conn, :index, organization)
    refute Repo.get(WhitelistedUrl, whitelisted_url.id)
  end
end
