defmodule DockupUi.DashboardController do
  use DockupUi.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end
