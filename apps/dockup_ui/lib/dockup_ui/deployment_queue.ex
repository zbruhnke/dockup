defmodule DockupUi.DeploymentQueue do
  use GenServer

  alias DockupUi.{
    Repo,
    Deployment,
    Callback
  }

  import Ecto.Query

  @default_max_concurrent_deployments 5
  @backend Application.fetch_env!(:dockup_ui, :backend_module)

  @doc """
  Starts the deployment queue
  """
  def start_link(name \\ __MODULE__, backend \\ @backend, callback \\ Callback) do
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
  def enqueue(deployment_params, name \\ __MODULE__) do
    GenServer.call(name, {:enqueue, deployment_params})
  end

  @doc """
  Returns the queued deployment params
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

  def handle_call({:enqueue, deployment_params}, _from, state) do
    {deployment, callback_data} = deployment_params
    callback = state.callback.lambda(deployment, callback_data)
    callback.(:queued, nil)

    process_queue(self())
    state = %{state | queue: :queue.in(deployment_params, state.queue)}
    {:reply, :ok, state}
  end

  def handle_call(:get_queue, _from, state) do
    {:reply, :queue.to_list(state.queue), state}
  end

  def handle_cast(:process, state) do
    queue =
      if current_deployment_count() < max_concurrent_deployments() do
        deploy_from_queue(state.queue, state.backend, state.callback)
      else
        state.queue
      end

    state = %{state | queue: queue}
    {:noreply, state}
  end

  defp deploy_from_queue(queue, backend, callback_module) do
    case :queue.out(queue) do
      {{:value, {deployment, callback_data}}, queue} ->
        callback = callback_module.lambda(deployment, callback_data)
        callback.(:processing, nil)
        backend.deploy(deployment, callback)
        queue
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

  defp max_concurrent_deployments do
    if val = System.get_env("DOCKUP_MAX_CONCURRENT_DEPLOYMENTS") do
      String.to_integer(val)
    else
      @default_max_concurrent_deployments
    end
  end
end
