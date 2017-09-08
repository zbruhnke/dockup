defmodule Dockup do
  @behaviour DockupSpec

  def initialize do
    Dockup.Config.set_configs_from_env()
    Dockup.Htpasswd.write()
  end

  def deploy(deployment, callback) do
    Dockup.DeployJob.spawn_process(deployment, callback)
  end

  def destroy(id, callback) do
    Dockup.DeleteDeploymentJob.spawn_process(id, callback)
  end
end
