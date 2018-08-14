defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    ContainerSpec,
    Container,
    Subdomain,
    Repo,
    BackendAdapter,
    NotificationChannel
  }

  alias Ecto.Multi

  import Ecto.Query

  @doc """
  Creates deployments, containers, ports and ingresses and deploys
  containers using the backend module.

  This also interpolates dockup variables in environment variables
  configured for containers. Supported dockup variables are:

  DOCKUP_SERVICE_<container name> - gets replaced by the hostname of a service
  which is part of this deployment.
  DOCKUP_ENDPOINT_<port> - gets replaced by the ingress endpoint of container
  in which this environment variable is defined.

  container_spec_params is a map of following data:
  [%{"id" => container_spec_id, "tag" => "new-tag"}]
  "new-tag" will override the default tag of the container_spec_id when
  containers of the blueprint of container_spec_id is deployed.
  """
  def run(container_spec_params, name \\ nil) do
    container_spec_params
    |> create_deployment(name)
    |> prepare_backend_containers()
    |> start_containers()
    |> update_container_handles()
    |> Repo.transaction()
  end

  # Returns a multi for creating a deployment along with the associated
  # models - containers, ports and ingresses
  defp create_deployment(container_spec_params, name) do
    container_specs = fetch_container_specs(container_spec_params)
    name = name || autogenerate_name(container_specs, container_spec_params)
    containers = prepare_containers(container_specs, container_spec_params)

    container_spec = Enum.at(container_specs, 0)
    blueprint_id = container_spec.blueprint_id

    deployment = %Deployment{blueprint_id: blueprint_id, status: "queued"}
    #TODO: also add the timestamps delete_at and hibernate_at
    Multi.insert(Multi.new, :deployment, Deployment.changeset(deployment, %{name: name, containers: containers}))
  end

  # From the deployment multi, prepares container structs which backend understands
  # Adds these backend containers to the multi and returns it
  defp prepare_backend_containers(multi) do
    Multi.run(multi, :backend_containers, fn %{deployment: deployment} ->
      deployment = Repo.preload(deployment, [containers: [container_spec: [:init_container_specs, port_specs: [ingress: :subdomain]]]])

      containers =
        Enum.map(deployment.containers, fn container ->
          {container.id, BackendAdapter.prepare_container(container)}
        end)

      {:ok, containers}
    end)
  end

  # From the backend_containers multi, starts each backend container
  # and returns a multi with a list of {<container_id>, <container_handle>}
  defp start_containers(multi) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)

    Multi.run(multi, :backend_response, fn %{backend_containers: containers} ->
      container_handles =
        Enum.map(containers, fn {id, container} ->
          {:ok, container_handle} = backend.start(container)
          {id, container_handle}
        end)

      {:ok, container_handles}
    end)
  end

  # From the backend_response multi, prepares multiple multi's for updating
  # containers with their handles. Returns a merged multi of all these updates.
  defp update_container_handles(multi) do
    Multi.merge(multi, fn %{backend_response: container_handles} ->
      get_merged_multi(Multi.new(), container_handles)
    end)
  end

  defp get_merged_multi(multi, []) do
    multi
  end

  defp get_merged_multi(multi, [{id, handle} | rest]) do
    changeset = Container.update_tag_changeset(id, handle)
    update_multi = Multi.update(Multi.new(), "update_handle_#{id}", changeset)

    multi
    |> Multi.append(update_multi)
    |> get_merged_multi(rest)
  end

  defp prepare_containers(container_specs, container_spec_params) do
    Enum.map(container_specs, fn container_spec ->
      %{
        tag: get_tag(container_spec_params, container_spec),
        container_spec_id: container_spec.id,
        ingresses: prepare_ingresses(container_spec.port_specs),
        status: "unknown"
      }
    end)
  end

  defp prepare_ingresses(port_specs) do
    Enum.map(port_specs, fn port_spec ->
      {endpoint, subdomain} = get_endpoint_if_public!(port_spec)

      %{
        port_spec_id: port_spec.id,
        endpoint: endpoint,
        subdomain: subdomain
      }
    end)
  end

  defp get_endpoint_if_public!(%{public: public}) do
    if public do
      base_domain = Application.fetch_env!(:dockup_ui, :base_domain)
      subdomain = get_unused_subdomain!()
      {"#{subdomain.subdomain}.#{base_domain}", subdomain}
    else
      {nil, nil}
    end
  end

  defp get_unused_subdomain!() do
    query =
      from s in Subdomain,
      where: is_nil(s.ingress_id),
      limit: 1

    case Repo.one(query) do
      nil ->
        NotificationChannel.send_notification("error", "No free subdomains. Create new ones or free up existing ones.")
        raise "No free subdomains"

      subdomain ->
        subdomain
    end
  end

  defp fetch_container_specs(container_spec_params) do
    container_spec_id = Enum.find_value(container_spec_params, fn %{"id" => id} -> id end)
    container = Repo.get!(ContainerSpec, container_spec_id)
    blueprint_id = container.blueprint_id

    query =
      from c in ContainerSpec,
      where: c.blueprint_id == ^blueprint_id,
      preload: [:port_specs, :init_container_specs],
      order_by: c.id

    Repo.all(query)
  end

  defp get_tag(container_spec_params, container_spec) do
    Enum.find_value(container_spec_params, fn %{"tag" => tag, "id" => spec_id} ->
      if spec_id == container_spec.id do
        tag
      else
        container_spec.default_tag
      end
    end)
  end

  defp autogenerate_name(container_specs, container_spec_params) do
    name =
      container_specs
      |> Enum.map(&({&1.name, get_tag(container_spec_params, &1), &1.default_tag}))
      |> Enum.filter(fn {_name, tag, default_tag} -> tag != default_tag end)
      |> Enum.map(fn {name, tag, _} -> "#{name}:#{tag}" end)
      |> Enum.join(", ")

    if name == "" do
      "default"
    else
      name
    end
  end
end
