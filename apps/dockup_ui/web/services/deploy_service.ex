defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  def run(repository, branch, callback_params \\ %{}, deps \\ []) when not is_nil(repository) do
    deploy_job = deps[:deploy_job] || @backend
    callback = deps[:callback] || DockupUi.Callback

    with \
      changeset <- Deployment.create_changeset(%Deployment{status: "queued"}, %{branch: branch, repository_id: repository.id}),
      {:ok, deployment} <- Repo.insert(changeset),
      deployment <- Repo.preload(deployment, :repository),
      callback_params <- Map.put(callback_params, :deployment, deployment),
      :ok <- deploy_project(deploy_job, callback_params, callback)
    do
      {:ok, deployment}
    end
  end

  defp deploy_project(deploy_job, callback_params, callback) do
    deploy_job.deploy(callback_params.deployment, callback.lambda(callback_params))
    :ok
  end
end
