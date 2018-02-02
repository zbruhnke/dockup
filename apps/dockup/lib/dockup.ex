defmodule Dockup do
  @behaviour DockupSpec

  @impl DockupSpec
  def initialize do
    Dockup.Config.set_configs_from_env()
    Dockup.Htpasswd.write()
    Dockup.Netrc.write()
  end

  @impl DockupSpec
  def deploy(deployment, callback) do
    Dockup.DeployJob.spawn_process(deployment, callback)
  end

  @impl DockupSpec
  def destroy(deployment, callback) do
    Dockup.DeleteDeploymentJob.spawn_process(deployment, callback)
  end
end
