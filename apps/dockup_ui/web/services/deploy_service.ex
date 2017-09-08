defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  def run(deployment_params, callback_data, deps \\ []) do
    deploy_job = deps[:deploy_job] || Dockup.DeployJob
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
    deploy_job.spawn_process(deployment, callback.lambda(deployment, callback_data))
    :ok
  end
end
