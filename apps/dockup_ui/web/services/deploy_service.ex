defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo
  }

  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  def run(repository, branch, deps \\ []) do
    deploy_job = deps[:deploy_job] || @backend
    callback = deps[:callback] || DockupUi.Callback

    with \
      changeset <- Deployment.create_changeset(%Deployment{status: "queued"}, %{branch: branch, repository_id: repository.id}),
      {:ok, deployment} <- Repo.insert(changeset),
      deployment <- Repo.preload(deployment, :repository),
      :ok <- deploy_project(deploy_job, deployment, callback)
    do
      {:ok, deployment}
    end
  end

  defp deploy_project(deploy_job, deployment, callback) do
    deploy_job.deploy(deployment, callback.lambda(deployment))
    :ok
  end
end
