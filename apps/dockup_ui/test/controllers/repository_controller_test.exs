defmodule DockupUi.RepositoryControllerTest do
  use DockupUi.ConnCase

  import DockupUi.Factory

  alias DockupUi.Repository
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
    conn = get conn, organization_repository_path(conn, :new, organization)
    assert html_response(conn, 200) =~ "New Repository"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, organization: organization} do
    conn = post conn, organization_repository_path(conn, :create, organization), repository: @valid_attrs
    assert redirected_to(conn) == organization_repository_path(conn, :new, organization)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    conn = post conn, organization_repository_path(conn, :create, organization), repository: @invalid_attrs
    assert html_response(conn, 200) =~ "New Repository"
  end

  test "renders form for editing chosen resource", %{conn: conn, organization: organization} do
    repository = Repo.insert! %Repository{organization_id: organization.id}
    conn = get conn, organization_repository_path(conn, :edit, organization, repository)
    assert html_response(conn, 200) =~ "Edit Repository"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, organization: organization} do
    repository = Repo.insert! %Repository{organization_id: organization.id}
    conn = put conn, organization_repository_path(conn, :update, organization, repository), repository: @valid_attrs
    assert redirected_to(conn) == organization_config_path(conn, :index, organization)
    assert Repo.get_by(Repository, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    repository = Repo.insert! %Repository{organization_id: organization.id}
    conn = put conn, organization_repository_path(conn, :update, organization, repository), repository: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Repository"
  end

  test "deletes chosen resource", %{conn: conn, organization: organization} do
    repository = Repo.insert! %Repository{organization_id: organization.id}
    conn = delete conn, organization_repository_path(conn, :delete, organization, repository)
    assert redirected_to(conn) == organization_config_path(conn, :index, organization)
    refute Repo.get(Repository, repository.id)
  end
end
