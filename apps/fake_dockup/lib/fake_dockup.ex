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
  def destroy(_id, callback) do
    callback.(:deleting_deployment, nil)
    Process.sleep(2000)

    callback.(:deployment_deleted, nil)
  end

  @impl DockupSpec
  def hibernate(_id, callback) do
    callback.(:hibernating_deployment, nil)
    Process.sleep(2000)

    callback.(:deployment_hibernated, nil)
  end

  @impl DockupSpec
  def wake_up(_id, callback) do
    callback.(:waking_up_deployment, nil)
    Process.sleep(2000)

    callback.(:checking_urls, "logio.example.com/#?projectName=project_id")
    Process.sleep(2000)

    callback.(:started, ["codemancers.com", "crypt.codemancers.com"])
  end
end
