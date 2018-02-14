defmodule FakeDockup.Scenario1 do
  @moduledoc """
  This is the happy path scenario.
  If an existing scenario cannot be found by matching the branch name
  from the deployment params, this scenario is chosen as a fallback.
  """

  def run(callback) do
    callback.(:cloning_repo, nil)
    Process.sleep(2000)

    callback.(:starting, nil)
    Process.sleep(2000)

    callback.(:checking_urls, "logio.example.com/#?projectName=project_id")
    Process.sleep(2000)

    callback.(:started, ["codemancers.com", "crypt.codemancers.com"])
  end
end
