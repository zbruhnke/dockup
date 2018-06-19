defmodule DockupUi.HibernateDeploymentService do
  require Logger

  alias DockupUi.{
    Deployment,
    Repo
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

  defp hibernate(deployment, callback) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    callback = DockupUi.Callback.lambda(deployment, callback)
    backend.hibernate(deployment.id, callback)
    :ok
  end
end
