defmodule DockupUi.DeleteDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentStatusUpdateService
  }

  def run(deployment_id, deps \\ []) do
    Logger.info "Deleting deployment with ID: #{deployment_id}"

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      {:ok, deployment} <- DeploymentStatusUpdateService.run("deleting", deployment.id),
      :ok <- delete_deployment(deployment)
    do
      {:ok, deployment}
    end
  end

  def run_for_restarting(deployment_id, deps \\ []) do
    Logger.info "Deleting deployment with ID: #{deployment_id} for attempting restart"

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      changeset <- Deployment.changeset(deployment, %{status: "restarting"}),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- DeploymentStatusUpdateService.run(deployment),
      :ok <- delete_deployment(deployment)
    do
      {:ok, deployment}
    end
  end

  def run_all(deployment_ids) when is_list deployment_ids do
    Enum.all? deployment_ids, fn deployment_id ->
      {result, _} = run(deployment_id)
      result == :ok
    end
  end

  defp delete_deployment(deployment) do
    deployment = Repo.preload(deployment, :containers)
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    for container <- deployment.containers do
      backend.delete(container.handle)
    end
    :ok
  end
end
