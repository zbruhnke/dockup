defmodule DockupUi.DeleteExpiredDeploymentsService do
  @moduledoc """
  This module is reponsible for fetching all deployments older than certain
  amount of time (as defined in config) and queueing them for deletiing using
  DeleteDeploymentService
  """

  import Ecto.Query, only: [from: 2]

  require Logger

  alias DockupUi.{
    DeleteDeploymentService,
    Deployment,
    Repo
  }

  def run(service \\ DeleteDeploymentService, retention_days \\ nil) do
    Logger.info "Running DeleteExpiredDeploymentsService"

    retention_days = retention_days || get_retention_days()
    query = from d in Deployment,
      where: d.inserted_at < ago(^retention_days, "day")

    query
    |> Repo.all
    |> Flow.from_enumerable()
    |> Flow.map(&service.run(&1))
    |> Flow.run()
  end

  defp get_retention_days() do
    System.get_env("DOCKUP_RETENTION_DAYS") || Application.fetch_env!(:dockup_ui, :retention_days)
  end
end
