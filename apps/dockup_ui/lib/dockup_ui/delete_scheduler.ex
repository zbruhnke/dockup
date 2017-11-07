defmodule DockupUi.DeleteScheduler do
  alias DockupUi.DeleteExpiredDeploymentsService
  use GenServer

  @interval_msec 60 * 60 * 1000

  @doc """
  Starts a Scheduler and kicks off the loop
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    set_timer()

    {:ok, nil}
  end

  def handle_info(:trigger, state) do
    DeleteExpiredDeploymentsService.run()
    set_timer()

    {:noreply, state}
  end

  defp set_timer do
    Process.send_after(self(), :trigger, @interval_msec)
  end
end
