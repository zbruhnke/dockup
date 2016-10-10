defmodule DockupUi.DeploymentController do
  use DockupUi.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def index(conn, _params) do
    render conn, "index.html"
  end
end
