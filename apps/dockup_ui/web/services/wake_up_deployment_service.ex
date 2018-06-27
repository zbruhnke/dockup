defmodule DockupUi.WakeUpDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentQueue
  }

  def wake_up_all do
    Deployment
    |> Ecto.Query.where(status: "hibernated")
    |> Repo.all()
    |> Enum.map(fn d -> run(d.id) end)
  end

  def run(deployment_id) do
    Logger.info("Waking up deployment with id: #{deployment_id}")

    with deployment <- Repo.get!(Deployment, deployment_id),
         :ok <- queue_deployment(deployment_id) do
      {:ok, deployment}
    end
  end

  defp queue_deployment(deployment_id) do
    DeploymentQueue.enqueue(deployment_id)
  end
end
