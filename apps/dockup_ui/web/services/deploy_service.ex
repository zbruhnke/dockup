defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentQueue
  }

  def run(deployment_params, deps \\ []) do
    deployment_queue = deps[:deployment_queue] || DeploymentQueue

    with \
      changeset <- Deployment.changeset(%Deployment{status: "queued"}, deployment_params),
      {:ok, deployment} <- Repo.insert(changeset),
      :ok <- queue_deployment(deployment.id, deployment_queue)
    do
      {:ok, deployment}
    end
  end

  defp queue_deployment(deployment_id, deployment_queue) do
    deployment_queue.enqueue(deployment_id)
  end
end
