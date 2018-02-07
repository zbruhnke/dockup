defmodule DockupUi.SlackWebhook do
  def send_message(webhook_url, message) do
    body = Poison.encode!(%{text: message, username: "Dockup"})
    spawn fn ->
      HTTPotion.post webhook_url, [
        body: body,
        headers: ["Content-Type": "application/json"]
      ]
    end
  end
end
