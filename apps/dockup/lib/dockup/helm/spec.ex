defmodule Dockup.Helm.Spec do
  @behaviour DockupSpec

  @impl DockupSpec
  def initialize do
  end

  @impl DockupSpec
  def deploy(deployment, callback) do
    Dockup.Helm.InstallJob.spawn_process(deployment, callback)
  end

  @impl DockupSpec
  def destroy(id, callback) do
    Dockup.Helm.DeleteJob.spawn_process(id, callback)
  end
end
