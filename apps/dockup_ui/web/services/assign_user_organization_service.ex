defmodule DockupUi.AssignUserOrganizationService do
  alias DockupUi.{
    Repo,
    User,
    UserOrganization,
    InvitationEmail,
    Mailer
  }

  alias Ecto.Multi

  def invite_user(organization, user_email) do
    case assign_user(organization, user_email) do
      {:ok, _} ->
        organization
        |> InvitationEmail.invitation_email(user_email)
        |> Mailer.deliver_later()
        {:ok, user_email}
      {:error, _} ->
        {:error, "Cannot invite user to organization."}
      {:error, _, _, _} ->
        {:error, "User already part of organization"}
    end
  end

  def assign_user(organization, user_email) do
    Multi.new()
    |> Multi.run(:user, fn _ -> find_or_create_user(user_email) end)
    |> Multi.run(:assign_user, fn %{user: user} -> assign_user_to_org(organization, user) end)
    |> Repo.transaction()
  end

  defp find_or_create_user(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        %User{}
        |> User.changeset(%{email: email})
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  defp assign_user_to_org(org, user) do
    %UserOrganization{}
    |> UserOrganization.changeset(%{user_id: user.id, organization_id: org.id})
    |> Repo.insert()
  end
end
