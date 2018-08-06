defmodule DockupUi.HibernateDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    DeploymentChannel,
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

    with \
       deployment <- Repo.get!(Deployment, deployment_id),
       changeset <-
         Deployment.changeset(deployment, %{status: "hibernating"}),
       {:ok, deployment} <- Repo.update(changeset),
       :ok <- DeploymentChannel.update_deployment_status(deployment),
       :ok <- hibernate(deployment)
     do
      {:ok, deployment}
    end
  end

  defp hibernate(deployment) do
    deployment = Repo.preload(deployment, :containers)
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    for container <- deployment.containers do
      backend.hibernate(container.handle)
    end
    :ok
  end
end
