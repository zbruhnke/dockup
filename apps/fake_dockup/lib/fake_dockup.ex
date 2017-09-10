defmodule FakeDockup do
  @behaviour DockupSpec

  def initialize do
  end

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

  def destroy(_id, callback) do
    callback.(:deleting_deployment, nil)
    Process.sleep(2000)

    callback.(:deployment_deleted, nil)
  end
end
