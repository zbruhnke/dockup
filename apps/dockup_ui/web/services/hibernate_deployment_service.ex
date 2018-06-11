defmodule DockupUi.HibernateDeploymentService do
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

  def run_all(deployment_ids) when is_list deployment_ids do
    Enum.all? deployment_ids, fn deployment_id ->
      {result, _} = run(deployment_id, %Null{})
      result == :ok
    end
  end

  defp hibernate(deployment, callback) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    callback = DockupUi.Callback.lambda(deployment, callback)
    backend.hibernate(deployment.id, callback)
    :ok
  end
end
