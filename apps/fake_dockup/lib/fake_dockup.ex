defmodule FakeDockup do
  @behaviour DockupSpec

  @impl DockupSpec
  def initialize do
    #NOOP
  end

  @impl DockupSpec
  def deploy(%{branch: branch}, callback) do
    module = Module.concat(FakeDockup, branch)

    module =
      if Code.ensure_loaded?(module) do
        module
      else
        FakeDockup.Scenario1
      end

    spawn(fn -> module.run(callback) end)
  end

  @impl DockupSpec
  def destroy(_deployment, callback) do
    callback.(:deleting_deployment, nil)
    Process.sleep(2000)

    callback.(:deployment_deleted, nil)
  end
end
