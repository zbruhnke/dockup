defmodule FakeDockup.Scenario1 do
  def run(callback) do
    callback.(:queued, nil)
    Process.sleep(2000)

    callback.(:cloning_repo, nil)
    Process.sleep(2000)

    callback.(:starting, "logio.example.com/#?projectName=project_id")
    Process.sleep(2000)

    callback.(:checking_urls, nil)
    Process.sleep(2000)

    callback.(:started, ["codemancers.com", "crypt.codemancers.com"])
  end
end
