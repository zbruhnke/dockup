defmodule Dockup.Backends.Compose do
  @behaviour DockupSpec

  require Logger

  @impl DockupSpec
  def initialize do
    Dockup.Config.set_configs_from_env()
    Dockup.Backends.Compose.Htpasswd.write()
    Dockup.Backends.Compose.Netrc.write()
  end

  @impl DockupSpec
  def deploy(deployment, callback) do
    Dockup.Backends.Compose.DeployJob.spawn_process(deployment, callback)
  end

  @impl DockupSpec
  def destroy(id, callback) do
    Dockup.Backends.Compose.DeleteDeploymentJob.spawn_process(id, callback)
  end

  @impl DockupSpec
  def hibernate(id, callback) do
    Logger.warn "Hibernate not supported in docker-compose backend"
    callback.update_status(id, "failed")
  end

  @impl DockupSpec
  def wake_up(id, callback) do
    Logger.warn "Wake up not supported in docker-compose backend"
    callback.update_status(id, "failed")
  end
end
