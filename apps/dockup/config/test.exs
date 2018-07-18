use Mix.Config

config :logger, backends: []
config :kazan, :server, {:kubeconfig, System.get_env("KUBECONFIG")}
