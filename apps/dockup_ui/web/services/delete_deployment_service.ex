defmodule DockupUi.DeleteDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Ingress,
    Subdomain,
    DeploymentStatusUpdateService
  }

  alias Ecto.Multi

  def run(deployment_id) do
    Logger.info "Deleting deployment with ID: #{deployment_id}"

    deployment = Repo.get!(Deployment, deployment_id)
    deployment = Repo.preload(deployment, [containers: [ingresses: :subdomain]])
    ingresses = Enum.flat_map(deployment.containers, &(&1.ingresses))
    subdomains = Enum.map(ingresses, &(&1.subdomain)) |> Enum.reject(&is_nil/1)

    {:ok, %{"deployment" => deployment}} =
      deployment
      |> update_deployment_status()
      |> clear_ingress_endpoints(ingresses)
      |> clear_subdomain_ingress_id(subdomains)
      |> publish_and_delete()
      |> Repo.transaction()

    {:ok, deployment}
  end

  defp update_deployment_status(deployment) do
    changeset = Deployment.changeset(deployment, %{status: "deleting"})

    Multi.new()
    |> Multi.update("deployment", changeset)
  end

  defp clear_ingress_endpoints(multi, ingresses) do
    Enum.reduce(ingresses, multi, fn ingress, multi ->
      changeset = Ingress.changeset(ingress, %{endpoint: nil})
      Multi.update(multi, "ingress_update_#{ingress.id}", changeset)
    end)
  end

  defp clear_subdomain_ingress_id(multi, subdomains) do
    IO.inspect subdomains
    Enum.reduce(subdomains, multi, fn subdomain, multi ->
      changeset = Subdomain.changeset(subdomain, %{ingress_id: nil})
      Multi.update(multi, "subdomain_update_#{subdomain.id}", changeset)
    end)
  end

  defp publish_and_delete(multi) do
    Multi.run(multi, "publish_and_delete", fn %{"deployment" => deployment} ->
      DeploymentStatusUpdateService.run(deployment)
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
