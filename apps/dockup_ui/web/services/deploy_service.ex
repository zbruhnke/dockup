defmodule DockupUi.DeployService do
  alias DockupUi.{
    Deployment,
    ContainerSpec,
    Subdomain,
    Repo
  }

  alias Ecto.Multi

  import Ecto.Query

  def run(deployment_params) do
    deployment_params
    |> create_deployment()
    |> start_containers()
    |> Repo.transaction()
  end

  defp create_deployment(deployment_params) do
    name = deployment_params["name"]
    container_specs = fetch_container_specs(deployment_params["container_specs"])
    containers = prepare_containers(container_specs, deployment_params["container_specs"])

    [container_spec, _] = container_specs
    blueprint_id = container_spec.blueprint_id

    deployment = %Deployment{blueprint_id: blueprint_id, status: "queued"}
    #TODO: also add the timestamps delete_at and hibernate_at
    Multi.insert(Multi.new, :deployment, Deployment.changeset(deployment, %{name: name, containers: containers}))
  end

  defp start_containers(multi) do
    Multi.run(multi, :start_containers, fn %{deployment: deployment} ->
      IO.inspect deployment
    end)
  end

  defp prepare_containers(container_specs, container_spec_params) do
    Enum.map(container_specs, fn container_spec ->
      %{
        tag: get_tag(container_spec_params, container_spec.id),
        container_spec_id: container_spec.id,
        ports: prepare_ports(container_spec.port_specs)
      }
    end)
  end

  defp prepare_ports(port_specs) do
    Enum.map(port_specs, fn port_spec ->
      {endpoint, subdomain} = get_unused_endpoint_if_public!(port_spec)

      %{
        port_spec_id: port_spec.id,
        endpoint: endpoint,
        subdomain: subdomain
      }
    end)
  end

  defp get_unused_endpoint_if_public!(%{public: public}) do
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
end
