defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    ContainerSpec,
    Subdomain,
    Repo,
    BackendAdapter
  }

  alias Ecto.Multi

  import Ecto.Query

  def run(container_spec_params, name \\ nil) do
    container_spec_params
    |> create_deployment(name)
    |> prepare_backend_containers()
    |> start_containers()
    |> Repo.transaction()
  end

  defp create_deployment(container_spec_params, name) do
    container_specs = fetch_container_specs(container_spec_params)
    name = name || autogenerate_name(container_specs, container_spec_params)
    containers = prepare_containers(container_specs, container_spec_params)

    [container_spec, _] = container_specs
    blueprint_id = container_spec.blueprint_id

    deployment = %Deployment{blueprint_id: blueprint_id, status: "queued"}
    #TODO: also add the timestamps delete_at and hibernate_at
    Multi.insert(Multi.new, :deployment, Deployment.changeset(deployment, %{name: name, containers: containers}))
  end

  defp prepare_backend_containers(multi) do
    Multi.run(multi, :backend_containers, fn %{deployment: deployment} ->
      containers = BackendAdapter.prepare_containers(deployment)
      {:ok, containers}
    end)
  end

  defp start_containers(multi) do
    Multi.run(multi, :backend_response, fn %{backend_containers: containers} ->
      IO.inspect containers
      {:ok, containers}
    end)
  end

  defp prepare_containers(container_specs, container_spec_params) do
    Enum.map(container_specs, fn container_spec ->
      %{
        tag: get_tag(container_spec_params, container_spec.id),
        container_spec_id: container_spec.id,
        ingresses: prepare_ingresses(container_spec.port_specs)
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
      where: is_nil(s.port_id),
      limit: 1

    Repo.one!(query)
  end

  defp fetch_container_specs(container_spec_params) do
    container_spec_ids = Enum.map(container_spec_params,  & &1["id"])

    query =
      from c in ContainerSpec,
      where: c.id in ^container_spec_ids,
      preload: [:port_specs, :init_container_specs]

    Repo.all(query)
  end

  defp get_tag(container_spec_params, id) do
    Enum.find_value(container_spec_params, fn %{"tag" => tag, "id" => spec_id} ->
      if spec_id == id do
        tag
      end
    end)
  end

  defp autogenerate_name(container_specs, container_spec_params) do
    name =
      container_specs
      |> Enum.map(&({&1.name, get_tag(container_spec_params, &1.id), &1.default_tag}))
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
