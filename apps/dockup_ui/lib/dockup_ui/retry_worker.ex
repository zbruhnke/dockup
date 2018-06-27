defmodule DockupUi.RetryWorker do
  use GenServer
  require Logger
  import Ecto.Query

  alias DockupUi.{
    Repo,
    Deployment,
    DeleteDeploymentService,
    DeploymentQueue
  }

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    starting_deployments = fetch_deployments_in_progress()
    starting_deployments
    |> Enum.each(&restart_deployment(&1))

    waking_up_deployments = fetch_waking_up_deployments()
    waking_up_deployments
    |> Enum.each(&DeploymentQueue.enqueue(&1))

    {:ok, nil}
  end

  defp restart_deployment(deployment) do
    DeleteDeploymentService.run_for_restarting(deployment.id)
  end

  defp fetch_deployments_in_progress do
    query =
      from d in Deployment,
      where: d.status in ["queued", "starting", "waiting_for_urls", "restarting"]

    Repo.all(query)
  end

  defp fetch_waking_up_deployments do
    query =
      from d in Deployment,
      where: d.status == "waking_up"

    Repo.all(query)
  end
end
