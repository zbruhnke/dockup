defmodule DockupUi.HibernateDeploymentService do
  require Ecto.Query
  require Logger

  alias DockupUi.{
    Deployment,
    Repo,
    Callback.Null
  }

  def run(deployment_id, callback_data) do
    Logger.info "Hibernate deployment with id: #{deployment_id}"

    with \
      deployment <- Repo.get!(Deployment, deployment_id),
      changeset <- Deployment.hibernate_changeset(deployment),
      {:ok, deployment} <- Repo.update(changeset),
      :ok <- hibernate(deployment, callback_data)
    do
      {:ok, deployment}
    end
  end

  def hibernate_all_deployed do
    statuses = ["started", "hibernating_deployment"]
    DockupUi.Deployment
    |> Ecto.Query.where([d], d.status in ^statuses)
    |> DockupUi.Repo.all
    |> Enum.map( fn (d) -> run(d.id, %Null{}) end)
  end

  defp hibernate(deployment, callback) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    callback = DockupUi.Callback.lambda(deployment, callback)
    backend.hibernate(deployment.id, callback)
    :ok
  end
end
