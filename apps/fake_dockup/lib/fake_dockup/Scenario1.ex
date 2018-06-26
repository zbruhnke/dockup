defmodule FakeDockup.Scenario1 do
  @moduledoc """
  This is the happy path scenario.
  If an existing scenario cannot be found by matching the branch name
  from the deployment params, this scenario is chosen as a fallback.
  """

  def run(id, callback) do
    Process.sleep(2000)

    callback.set_log_url(id, "logio.example.com/#?projectName=project_id")
    callback.update_status(id, "waiting_for_urls")
    Process.sleep(2000)

    callback.set_urls(id, ["codemancers.com", "crypt.codemancers.com"])
    callback.update_status(id, "started")
  end
end
