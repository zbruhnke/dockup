defmodule DockupUi.Synchronizer do
  use GenServer
  require Logger
  import Ecto.Query

  alias DockupUi.{
    Deployment,
    Container,
    Repo,
    DeploymentStatusUpdateService,
    ContainerStatusUpdateService
  }
  alias Ecto.Multi

  @interval_msec 5000

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    send self(), :run
    {:ok, nil}
  end

  def handle_info(:run, state) do
    synchronize()
    start_timer()
    {:noreply, state}
  end

  defp start_timer do
    Process.send_after(self(), :run, @interval_msec)
  end

  defp synchronize do
    transient_states = Deployment.transient_states()
    query =
      from d in Deployment,
      where: d.status in(^transient_states),
      preload: [:containers]

    deployments = Repo.all(query)
    Enum.each(deployments, &update_status/1)
  end

  defp update_status(deployment) do
    deployment
    |> get_container_statuses()
    |> update_container_statuses()
    |> update_deployment_status(deployment)
    # Also update statuses via websockets here
    |> publish_status_update()
    |> run_in_transaction()
  end

  defp get_container_statuses(deployment) do
    Enum.map(deployment.containers, fn container ->
      backend = Application.fetch_env!(:dockup_ui, :backend_module)
      {container, backend.status(container.handle)}
    end)
  end

  defp update_container_statuses(containers_and_statuses) do
    Enum.reduce(containers_and_statuses, {Multi.new(), []}, fn ({container, status}, {multi, statuses}) ->
      if(container.status != status) do
        changeset = Container.status_update_changeset(container, status)
        {Multi.update(multi, "status-#{container.id}", changeset), [status | statuses]}
      else
        {multi, [status | statuses]}
      end
    end)
  end

  defp update_deployment_status({multi, container_statuses}, deployment) do
    new_deployment_status = get_deployment_status(container_statuses, deployment.status)

    if new_deployment_status && new_deployment_status != deployment.status do
      attrs =
        if new_deployment_status == "started" do
          %{status: new_deployment_status, deployed_at: DateTime.utc_now()}
        else
          %{status: new_deployment_status}
        end

      changeset = Deployment.changeset(deployment, attrs)
      Multi.update(multi, "deployment_status", changeset)
    else
      multi
    end
  end

  defp publish_status_update(multi) do
    if Multi.to_list(multi) == [] do
      multi
    else
      Multi.run(multi, "publish_status_update", fn changes ->
        Enum.each(changes, fn
          {"status-" <> _, container} ->  ContainerStatusUpdateService.run(container)
          {"deployment_status", deployment} -> DeploymentStatusUpdateService.run(deployment)
        end)

        {:ok, :ok}
      end)
    end
  end

  defp run_in_transaction(multi) do
    if Multi.to_list(multi) != [] do
      Repo.transaction(multi)
    end
  end

  defp get_deployment_status(container_statuses, deployment_status) when deployment_status in ~w(hibernating deleting) do
    if Enum.all?(container_statuses, &(&1 == "unknown")) do
      case deployment_status do
        "hibernating" -> "hibernated"
        "deleting" -> "deleted"
      end
    end
  end
  defp get_deployment_status(container_statuses, _) do
    cond do
      "failed" in container_statuses -> "failed"
      "pending" in container_statuses -> "starting"
      Enum.all?(container_statuses, &(&1 == "running")) -> "started"
      true -> nil
    end
  end
end
