use Mix.Config

config :kazan, :server, {:kubeconfig, System.get_env("KUBECONFIG")}
