defmodule DockupUi.DeleteExpiredDeploymentsService do
  @moduledoc """
  This module is reponsible for fetching all deployments older than certain
  amount of time (as defined in config) and queueing them for deletiing using
  DeleteDeploymentService
  """

  import Ecto.Query, only: [from: 2]

  alias DockupUi.{
    DeleteDeploymentService,
    Deployment,
    Repo
  }

  def run(service \\ DeleteDeploymentService, retention_days \\ nil) do
    retention_days = retention_days || Application.fetch_env!(:dockup, :deployment_retention_days)
    query = from d in Deployment,
      where: d.inserted_at < ago(^retention_days, "day"),
      select: d.id

    query
    |> Repo.all
    |> Enum.each(&service.run/1)
  end
end
