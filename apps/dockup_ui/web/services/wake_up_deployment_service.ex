defmodule DockupUi.WakeUpDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Callback.Null
  }

  def run(deployment_id, callback_data) do
    Logger.info "waking up deployment with id: #{deployment_id}"

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      :ok <- wake_up(deployment, callback_data)
    do
      {:ok, deployment}
    end
  end

  def wake_up_all_hibernated do
    DockupUi.Deployment
    |> Ecto.Query.where(status: "deployment_hibernated")
    |> DockupUi.Repo.all
    |> Enum.map( fn (d) -> run(d.id, %Null{}) end)
  end

  defp wake_up(deployment, callback) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    callback = DockupUi.Callback.lambda(deployment, callback)
    backend.wake_up(deployment.id, callback)
    :ok
  end
end
