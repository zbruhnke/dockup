defmodule DockupUi.SlackNotification do
  alias DockupUi.Repo

  def send(deployment) do
    deployment = Repo.preload(deployment, [:blueprint, :containers])
    deployment_url =
      DockupUi.Router.Helpers.deployment_url(DockupUi.Endpoint, :show, deployment.id)

    message = "Deployed `#{deployment.name}` of `#{deployment.blueprint.name}`: <#{deployment_url}>"
    send_message(message)
  end

  defp send_message(message) do
    if url = Application.get_env(:dockup_ui, :slack_webhook_url) do
      body = Poison.encode!(%{text: message, username: "Dockup"})
      spawn fn ->
        HTTPotion.post url, [
          body: body,
          headers: ["Content-Type": "application/json"]
        ]
      end
    end
  end
end
