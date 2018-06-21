defmodule DockupUi.Scheduler do
  alias DockupUi.DeleteExpiredDeploymentsService
  use GenServer
  require Logger

  @interval_delete_msec 60 * 60 * 1000

  @doc """
  Starts a Scheduler and kicks off the loop
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    set_delete_timer()

    case Application.get_env(:dockup_ui, :hibernate_all_at) do
      nil -> Logger.info("Won't be hibernating any deployments")
      _ -> set_hibernate_all_timer()
    end

    case Application.get_env(:dockup_ui, :wakeup_all_at) do
      nil -> Logger.info("Won't be waking up any deployments")
      _ -> set_wakeup_all_timer()
    end

    {:ok, nil}
  end

  def handle_info(:delete_unused, state) do
    DeleteExpiredDeploymentsService.run()
    set_delete_timer()

    {:noreply, state}
  end

  def handle_info(:hibernate_all, state) do
    DockupUi.HibernateDeploymentService.hibernate_all()
    set_hibernate_all_timer()

    {:noreply, state}
  end

  def handle_info(:wakeup_all, state) do
    DockupUi.WakeUpDeploymentService.wake_up_all()
    set_wakeup_all_timer()

    {:noreply, state}
  end

  defp set_delete_timer do
    Process.send_after(self(), :delete_unused, @interval_delete_msec)
  end

  defp set_hibernate_all_timer do
    time_interval = time_interval_from_now(:hibernate_all_at)
    Logger.info("Scheduling hibernation after #{time_interval} ms")
    Process.send_after(self(), :hibernate_all, time_interval)
  end

  defp set_wakeup_all_timer do
    time_interval = time_interval_from_now(:wakeup_all_at)
    Logger.info("Scheduling waking up after #{time_interval} ms")
    Process.send_after(self(), :wakeup_all, time_interval)
  end

  defp time_interval_from_now(scheduled_at_env_key) do
    {:ok, scheduled_at} =
      Application.get_env(:dockup_ui, scheduled_at_env_key)
      |> Time.from_iso8601

    time_difference = Time.diff(scheduled_at, Time.utc_now, :millisecond)
    if time_difference > 0 do   # 20:30 > 15:40
      time_difference
    else
      # Subtract from a day
      (24 * 60 * 60 * 1000)  + time_difference
    end
  end
end
