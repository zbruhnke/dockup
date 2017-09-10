use Mix.Config

config :dockup,
  workdir: "test/fixtures/workdir",
  htpasswd_dir: "test/fixtures/htpasswd",
  start_server: false

config :logger, backends: []
