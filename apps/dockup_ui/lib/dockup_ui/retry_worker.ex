defmodule DockupUi.RetryWorker do
  use GenServer
  require Logger
  import Ecto.Query

  alias DockupUi.{
    Repo,
    Deployment,
    DeploymentQueue,
    DeleteDeploymentService
  }

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__, deployment_queue: DeploymentQueue)
  end

  def init(_) do
    deployments = fetch_deployments_in_progress()

    deployments
    |> Enum.each(&retry_deployment(&1))
    {:ok, deployments}
  end

  defp retry_deployment(deployment) do
    DeleteDeploymentService.run_for_restarting(deployment.id)
  end

  defp fetch_deployments_in_progress() do
    query =
      from d in Deployment,
      where: d.status in ["queued", "starting", "waiting_for_urls", "restarting"]

    Repo.all(query)
  end
end
