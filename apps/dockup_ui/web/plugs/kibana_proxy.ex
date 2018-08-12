defmodule DockupUi.Plugs.KibanaProxy do
  require IEx
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    request_path = String.split(conn.request_path, "/logs") |> List.last
    # TODO: Fix the below
    # kibana_url = Application.get_env(:dockup_ui, :kibana_url)
    proxy_path = "http://localhost:5601#{request_path}"
    opts = PlugProxy.init(url: proxy_path)
    PlugProxy.call(conn, opts)
  end
end
