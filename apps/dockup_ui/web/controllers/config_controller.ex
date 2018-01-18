defmodule DockupUi.ConfigController do
  use DockupUi.Web, :controller

  alias DockupUi.WhitelistedUrl

  def index(conn, _params) do
    whitelisted_urls = Repo.all(WhitelistedUrl)
    render(conn, "index.html", whitelisted_urls: whitelisted_urls)
  end
end
