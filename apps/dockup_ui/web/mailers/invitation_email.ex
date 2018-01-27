defmodule DockupUi.InvitationEmail do
  import Bamboo.Email

  def invitation_email(organization, email) do
    login_url = DockupUi.Router.Helpers.deployment_url(DockupUi.Endpoint, :home)
    from = Application.get_env(:dockup_ui, :from_email)

    body = """
    Hello!

    You have been invited to join the organization: <strong>#{organization.name}</strong>.
    Sign up/log in using this email address to access the organization using <a href="#{login_url}" target="_blank">this link.</a>
    """

    new_email(
      to: email,
      from: from,
      subject: "Welcome to Dockup",
      html_body: body
    )
  end
end
