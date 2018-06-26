defmodule FakeDockup do
  @behaviour DockupSpec

  @impl DockupSpec
  def initialize do
    #NOOP
  end

  @impl DockupSpec
  def deploy(%{branch: branch, id: id}, callback) do
    module = Module.concat(FakeDockup, branch)

    module =
      if Code.ensure_loaded?(module) do
        module
      else
        FakeDockup.Scenario1
      end

    spawn(fn -> module.run(id, callback) end)
  end

  @impl DockupSpec
  def destroy(id, callback) do
    callback.update_status(id, "deleting")
    Process.sleep(2000)

    callback.update_status(id, "deleted")
  end

  @impl DockupSpec
  def hibernate(id, callback) do
    callback.update_status(id, "hibernating")
    Process.sleep(2000)

    callback.update_status(id, "hibernated")
  end

  @impl DockupSpec
  def wake_up(id, callback) do
    Process.sleep(2000)

    callback.set_log_url(id, "logio.example.com/#?projectName=project_id")
    callback.update_status(id, "waiting_for_urls")
    Process.sleep(2000)

    callback.set_urls(id, ["codemancers.com", "crypt.codemancers.com"])
    callback.update_status(id, "started")
  end
end
