defmodule DockupUi.InvitationController do
  use DockupUi.Web, :controller

  alias DockupUi.{
    AssignUserOrganizationService,
    User
  }

  def new(conn, _params) do
    changeset = User.invitation_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    organization = find_org(conn)
    case AssignUserOrganizationService.invite_user(organization, email) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User invited.")
        |> redirect(to: organization_invitation_path(conn, :new, conn.params["organization_id"]))
      {:error, msg} ->
        changeset = User.invitation_changeset(%User{email: email})
        conn
        |> put_flash(:error, msg)
        |> render("new.html", changeset: changeset)
    end
  end

  defp find_org(conn) do
    Enum.find conn.assigns[:current_user_orgs], fn org ->
      org.id == String.to_integer(conn.params["organization_id"])
    end
  end
end

