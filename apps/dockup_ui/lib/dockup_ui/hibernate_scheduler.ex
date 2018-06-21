defmodule DockupUi.HibernateScheduler do
  use GenServer
  require Logger

  @doc """
  Starts a Scheduler and kicks off the loop
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    case Application.get_env(:dockup_ui, :hibrenate_all_at) do
      nil -> Logger.info("Won't be hibernating any deployments")
      _ -> set_timer()
    end

    {:ok, nil}
  end

  def handle_info(:trigger, state) do
    DockupUi.HibernateDeploymentService.hibernate_all()
    set_timer()

    {:noreply, state}
  end

  defp set_timer do
    {:ok, hibernate_at} =
      Application.get_env(:dockup_ui, :hibrenate_all_at)
      |> Time.from_iso8601

    time_difference = Time.diff(hibernate_at, Time.utc_now, :millisecond)
    time_interval =
      if time_difference > 0 do   # 20:30 > 15:40
        time_difference
      else
        (24 * 60 * 60 * 1000)  + time_difference
      end

    Logger.info("Scheduling hibernation after #{time_interval} ms")
    Process.send_after(self(), :trigger, time_interval)
  end
end
