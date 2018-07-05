defmodule DockupUi.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Overrides configurations from ENV variables
    DockupUi.Config.set_configs_from_env()
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    backend.initialize()

    # Set id and secret for google oauth config here
    Application.put_env :ueberauth,
      Ueberauth.Strategy.Google.OAuth,
      [client_secret: Application.get_env(:dockup_ui, :google_client_secret),
       client_id: Application.get_env(:dockup_ui, :google_client_id)]

    children = [
      # Start the endpoint when the application starts
      supervisor(DockupUi.Endpoint, []),
      # Start the Ecto repository
      supervisor(DockupUi.Repo, []),
      worker(DockupUi.Scheduler, []),
      worker(DockupUi.DeploymentQueue, [])
    ]

    opts = [strategy: :one_for_one, name: DockupUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DockupUi.Endpoint.config_change(changed, removed)
    :ok
  end
end
