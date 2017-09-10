defmodule DockupUi.DeleteDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Callback.Web
  }

  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  def run(deployment_id, deps \\ []) do
    Logger.info "Deleting deployment with ID: #{deployment_id}"

    delete_deployment_job = deps[:delete_deployment_job] || @backend
    callback = deps[:callback] || DockupUi.Callback

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      :ok <- delete_deployment(delete_deployment_job, deployment, %Web{callback_url: deployment.callback_url}, callback)
    do
      {:ok, deployment}
    end
  rescue
    e ->
      Logger.error "Cannot schedule deployment for deployment_id: #{deployment_id}. Error: #{inspect e}"
      {:error, deployment_id}
  end

  defp delete_deployment(delete_deployment_job, deployment, callback_data, callback) do
    delete_deployment_job.destroy(deployment.id, callback.lambda(deployment, callback_data))
    :ok
  end
end
