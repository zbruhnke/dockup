defmodule DockupUi do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # If dockup is loaded (running umbrella apps), set the runtime configs
    # from environment variables
    if dockup_loaded?() do
      Logger.debug "Setting configuration from environment variables"
      Dockup.Config.set_configs_from_env()
      Dockup.Htpasswd.write()
    end

    children = [
      # Start the endpoint when the application starts
      supervisor(DockupUi.Endpoint, []),
      # Start the Ecto repository
      supervisor(DockupUi.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DockupUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DockupUi.Endpoint.config_change(changed, removed)
    :ok
  end

  defp dockup_loaded? do
    List.keymember?(Application.loaded_applications, :dockup, 0)
  end
end
