defmodule DockupUi.Application do
  use Application

  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Overrides configurations from ENV variables
    DockupUi.Config.set_configs_from_env()
    @backend.initialize()

    import Supervisor.Spec


    children = [
      # Start the endpoint when the application starts
      supervisor(DockupUi.Endpoint, []),
      # Start the Ecto repository
      supervisor(DockupUi.Repo, []),
      worker(DockupUi.DeleteScheduler, [])
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
