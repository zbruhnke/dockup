use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :dockup_ui, DockupUi.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/webpack/bin/webpack.js", "--mode", "development", "--watch",
      cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :dockup_ui, DockupUi.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :dockup_ui, DockupUi.Repo,
  adapter: Ecto.Adapters.Postgres,
  #username: "postgres",
  #password: "postgres",
  database: "dockup_ui_dev",
  hostname: "localhost",
  pool_size: 10,
  extensions: [{Postgrex.Extensions.JSON, [library: Poison]}]
