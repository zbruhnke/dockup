defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  def run(deployment_params, callback_data, deps \\ []) do
    deploy_job = deps[:deploy_job] || @backend
    callback = deps[:callback] || DockupUi.Callback

    with \
      changeset <- Deployment.create_changeset(%Deployment{status: "queued"}, deployment_params),
      {:ok, deployment} <- Repo.insert(changeset),
      :ok <- deploy_project(deploy_job, deployment, callback_data, callback)
    do
      {:ok, deployment}
    end
  end

  defp deploy_project(deploy_job, deployment, callback_data, callback) do
    deploy_job.deploy(deployment, callback.lambda(deployment, callback_data))
    :ok
  end
end
