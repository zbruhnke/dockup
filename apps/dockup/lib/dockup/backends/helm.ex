defmodule Dockup.Backends.Helm do
  @behaviour DockupSpec

  @impl DockupSpec
  def initialize do
    Dockup.Config.set_configs_from_env()
  end

  @impl DockupSpec
  def deploy(deployment, callback) do
    Dockup.Backends.Helm.InstallJob.spawn_process(deployment, callback)
  end

  @impl DockupSpec
  def destroy(id, callback) do
    Dockup.Backends.Helm.DeleteJob.spawn_process(id, callback)
  end

  @impl DockupSpec
  def hibernate(id, callback) do
    Dockup.Backends.Helm.HibernateJob.spawn_process(id, callback)
  end
end
