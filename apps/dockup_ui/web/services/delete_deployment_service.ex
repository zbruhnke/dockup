defmodule DockupUi.DeleteDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentChannel
  }

  alias Ecto.Multi

  def run(deployment_id) do
    Logger.info "Deleting deployment with ID: #{deployment_id}"

    deployment = Repo.get!(Deployment, deployment_id)
    deployment = Repo.preload(deployment, [containers: [ingresses: :subdomain]])
    ingresses = Enum.flat_map(deployment.containers, &(&1.ingresses))

    {:ok, %{"deployment" => deployment}} =
      deployment
      |> update_deployment_status()
      |> delete_ingress_endpoints(ingresses)
      |> publish_and_delete()
      |> Repo.transaction()

    {:ok, deployment}
  end

  defp update_deployment_status(deployment) do
    changeset = Deployment.changeset(deployment, %{status: "deleting"})

    Multi.new()
    |> Multi.update("deployment", changeset)
  end

  defp delete_ingress_endpoints(multi, ingresses) do
    Enum.reduce(ingresses, multi, fn ingress, multi ->
      Multi.delete(multi, "ingress_delete_#{ingress.id}", ingress)
    end)
  end

  defp publish_and_delete(multi) do
    Multi.run(multi, "publish_and_delete", fn %{"deployment" => deployment} ->
      DeploymentChannel.update_deployment_status(deployment)
      delete_deployment(deployment)

      {:ok, :ok}
    end)
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
