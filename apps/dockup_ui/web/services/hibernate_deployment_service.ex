defmodule DockupUi.HibernateDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    DeploymentStatusUpdateService,
    Callback,
    Deployment,
    Repo
  }

  def hibernate_all do
    statuses = ["started", "hibernating"]

    Deployment
    |> Ecto.Query.where([d], d.status in ^statuses)
    |> Repo.all()
    |> Enum.map(fn d -> run(d.id) end)
  end

  def run(deployment_id) do
    Logger.info("Hibernate deployment with id: #{deployment_id}")

    with {:ok, deployment} <- DeploymentStatusUpdateService.run("hibernating", deployment_id),
         :ok <- hibernate(deployment) do
      {:ok, deployment}
    end
  end

  defp hibernate(deployment) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    backend.hibernate(deployment.id, Callback)
    :ok
  end
end
