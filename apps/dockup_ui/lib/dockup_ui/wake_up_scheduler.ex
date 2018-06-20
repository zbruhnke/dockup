defmodule DockupUi.WakeUpScheduler do
  use GenServer
  require Logger

  @doc """
  Starts a Scheduler and kicks off the loop
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    case System.get_env("DOCKUP_WAKEUP_ALL_AT") do
      "-1" -> Logger.info("Won't be waking up any deployments")
      nil -> Logger.info("Won't be waking up any deployments")
      _ -> set_timer()
    end

    {:ok, nil}
  end

  def handle_info(:trigger, state) do
    DockupUi.WakeUpDeploymentService.wake_up_all_hibernated()
    set_timer()

    {:noreply, state}
  end

  defp set_timer do
    {:ok, wake_up_at} = System.get_env("DOCKUP_WAKEUP_ALL_AT")
                          |> Time.from_iso8601

    time_difference = Time.diff(wake_up_at, Time.utc_now, :millisecond)
    time_interval =
      if time_difference > 0 do   # 20:30 > 15:40
        time_difference
      else
        (24 * 60 * 60 * 1000)  + time_difference
      end

    Logger.info("Scheduling waking up after #{time_interval} ms")
    Process.send_after(self(), :trigger, time_interval)
  end
end
