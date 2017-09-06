use Mix.Config

config :dockup,
  command_module: Dockup.FakeCommand,
  workdir: "test/fixtures/workdir",
  htpasswd_dir: "test/fixtures/htpasswd",
  start_server: false

config :logger, backends: []
