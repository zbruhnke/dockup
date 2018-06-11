defmodule Dockup.Backends.Compose do
  @behaviour DockupSpec

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
  def hibernate(_id, callback) do
    callback.(:errored, "Hibernate not supported")
  end

  @impl DockupSpec
  def wake_up(_id, callback) do
    callback.(:errored, "Wake up not supported")
  end
end
