defmodule FakeDockup do
  @behaviour DockupSpec

  def initialize do
  end

  def deploy(%{branch: branch}, callback) do
    module = Module.concat(FakeDockup, branch)
    if Code.ensure_loaded?(module) do
      spawn(fn -> module.run(callback) end)
    else
      message = """
      #{branch} is not a valid scenario.
      Try `Scenario1` or check `apps/fake_dockup/lib/fake_dockup` to
      see all available scenarios.
      """
      callback.(:deployment_failed, message)
    end
  end

  def destroy(_id, callback) do
    callback.(:deleting_deployment, nil)
    Process.sleep(2000)

    callback.(:deployment_deleted, nil)
  end
end
