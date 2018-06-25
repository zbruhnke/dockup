defmodule DockupUi.DeploymentQueue do
  use GenServer

  alias DockupUi.{
    Repo,
    Deployment,
    Callback
  }

  import Ecto.Query

  @default_max_concurrent_deployments 5
  @default_max_concurrent_builds 2

  @doc """
  Starts the deployment queue
  """
  def start_link(name \\ __MODULE__,
                 backend \\ Application.fetch_env!(:dockup_ui, :backend_module),
                 callback \\ Callback) do
    state = %{
      backend: backend,
      callback: callback,
      queue: :queue.new()
    }
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @doc """
  Queues a deployment
  """
  def enqueue(deployment_id, name \\ __MODULE__) do
    GenServer.call(name, {:enqueue, deployment_id})
  end

  @doc """
  Returns the queued deployments
  """
  def get_queue(name \\ __MODULE__) do
    GenServer.call(name, :get_queue)
  end

  @doc """
  Tries to process deployments from the queue
  """
  def process_queue(name \\ __MODULE__) do
    GenServer.cast(name, :process)
  end

  @doc """
  Returns true if queue is alive
  """
  def alive?(name \\ __MODULE__) do
    GenServer.whereis(name) != nil
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:enqueue, deployment_id}, _from, state) do
    process_queue(self())
    state = %{state | queue: :queue.in(deployment_id, state.queue)}
    {:reply, :ok, state}
  end

  def handle_call(:get_queue, _from, state) do
    {:reply, :queue.to_list(state.queue), state}
  end

  def handle_cast(:process, state) do
    queue =
      if has_capacity_to_deploy?() do
        deploy_from_queue(state.queue, state.backend, state.callback)
      else
        state.queue
      end

    state = %{state | queue: queue}
    {:noreply, state}
  end

  defp has_capacity_to_deploy? do
    current_deployment_count() < max_concurrent_deployments() &&
      current_build_count() < max_concurrent_builds()
  end

  defp deploy_from_queue(queue, backend, callback_module) do
    case :queue.out(queue) do
      {{:value, deployment_id}, queue} ->
        deployment = Repo.get!(Deployment, deployment_id)

        # There is a chance that the deployment may have been
        # deleted. In that case, we should skip to the next item in the queue.
        if deployable?(deployment) do
          backend.deploy(deployment, callback_module)
          queue
        else
          deploy_from_queue(queue, backend, callback_module)
        end
      {:empty, queue} ->
        queue
    end
  end

  defp current_deployment_count do
    query =
      from d in Deployment,
      where: d.status not in ["queued", "deployment_deleted"]

    Repo.aggregate(query, :count, :id)
  end

  defp current_build_count do
    query =
      from d in Deployment,
      where: d.status in ["processing", "cloning_repo", "starting"]

    Repo.aggregate(query, :count, :id)
  end

  defp max_concurrent_deployments do
    if val = System.get_env("DOCKUP_MAX_CONCURRENT_DEPLOYMENTS") do
      String.to_integer(val)
    else
      @default_max_concurrent_deployments
    end
  end

  defp max_concurrent_builds do
    if val = System.get_env("DOCKUP_MAX_CONCURRENT_BUILDS") do
      String.to_integer(val)
    else
      @default_max_concurrent_builds
    end
  end

  defp deployable?(%{id: id}) do
    Repo.get_by(Deployment, id: id, status: "queued")
  end
end
