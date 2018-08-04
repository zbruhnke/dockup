defmodule DockupUi.WakeUpDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentQueue,
    DeploymentStatusUpdateService
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
         changeset <- Deployment.changeset(deployment, %{status: "waking_up"}),
         {:ok, deployment} <- Repo.update(changeset),
         :ok <- DeploymentStatusUpdateService.run(deployment),
         :ok <- wake_up(deployment) do
      {:ok, deployment}
    end
  end

  defp wake_up(deployment) do
    deployment = Repo.preload(deployment, :containers)
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    for container <- deployment.containers do
      backend.wake_up(container.handle)
    end
    :ok
  end
end
