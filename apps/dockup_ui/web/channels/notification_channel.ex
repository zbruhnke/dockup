defmodule DockupUi.NotificationChannel do
  use Phoenix.Channel

  alias DockupUi.Endpoint

  def send_notification(type, message) do
    Endpoint.broadcast("notifications", "notification", %{type: type, message: message})
  end

  def join("notifications", _message, socket) do
    {:ok, socket}
  end
end

