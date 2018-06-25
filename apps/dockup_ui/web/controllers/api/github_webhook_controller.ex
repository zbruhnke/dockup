defmodule DockupUi.API.GithubWebhookController do
  use DockupUi.Web, :controller

  require Logger

  # TODO: This functionality will be changed once we have k8s support.
  # Removing temporarily.
  def create(conn, _params) do
    Logger.info "Dockup received an unknown event from Github which will be ignored."
    send_resp(conn, :bad_request, "Unknown github webhook event")
  end
end
