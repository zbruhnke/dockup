defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    Repo,
    DeploymentQueue
  }

  def run(deployment_params, callback_data, deps \\ []) do
    deployment_queue = deps[:deployment_queue] || DeploymentQueue

    with \
      changeset <- Deployment.create_changeset(%Deployment{status: "queued"}, deployment_params),
      {:ok, deployment} <- Repo.insert(changeset),
      :ok <- queue_deployment(deployment, callback_data, deployment_queue)
    do
      {:ok, deployment}
    end
  end

  defp queue_deployment(deployment, callback_data, deployment_queue) do
    deployment_queue.enqueue({deployment, callback_data})
  end
end
