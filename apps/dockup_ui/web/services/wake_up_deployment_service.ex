defmodule DockupUi.WakeUpDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Callback
  }

  def run(deployment_id) do
    Logger.info "Waking up deployment with id: #{deployment_id}"

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      :ok <- wake_up(deployment)
    do
      {:ok, deployment}
    end
  end

  defp wake_up(deployment) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    backend.wake_up(deployment.id, Callback)
    :ok
  end
end
