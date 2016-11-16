defmodule DockupUi.DeleteDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Callback.Web
  }

  def run(deployment_id, deps \\ []) do
    Logger.info "Deleting deployment with ID: #{deployment_id}"

    delete_deployment_job = deps[:delete_deployment_job] || Dockup.DeleteDeploymentJob
    callback = deps[:callback] || DockupUi.Callback

    deployment = Repo.get!(Deployment, deployment_id)
    callback_data = %Web{callback_url: deployment.callback_url}

    with \
      :ok <- delete_deployment(delete_deployment_job, deployment, callback_data, callback)
    do
      {:ok, deployment}
    end
  end

  defp delete_deployment(delete_deployment_job, deployment, callback_data, callback) do
    delete_deployment_job.spawn_process(deployment.id, callback.lambda(deployment, callback_data))
    :ok
  end
end
