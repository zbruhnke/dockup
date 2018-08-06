defmodule DockupUi.Endpoint do
  use Phoenix.Endpoint, otp_app: :dockup_ui

  socket "/socket", DockupUi.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :dockup_ui, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_dockup_ui_key",
    signing_salt: "vhxBVc+D"

  plug DockupUi.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.
  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      config_from_env_vars =
        config
        |> load_port_from_system_env
        |> load_host_from_system_env

      {:ok, config_from_env_vars}
    else
      {:ok, config}
    end
  end

  defp load_port_from_system_env(config) do
    port = System.get_env("PORT") ||
      raise "expected the PORT environment variable to be set"

    Keyword.put(config, :http, [:inet6, port: port])
  end

  defp load_host_from_system_env(config) do
    base_domain = System.get_env("DOCKUP_BASE_DOMAIN") ||
      raise "expected DOCKUP_BASE_DOMAIN env var to be set"

    put_in(config, [:url, :host], base_domain)
  end
end
