defmodule DockupUi.BackendAdapter do
  alias DockupUi.Repo

  def prepare_containers(deployment) do
    deployment = Repo.preload(deployment, [containers: [container_spec: [:init_container_specs, port_specs: [ingress: :subdomain]]]])

    Enum.map(deployment.containers, &prepare_container/1)
  end

  def prepare_container(container) do
    container_spec = container.container_spec

    %Dockup.Container{
      id: container.id,
      name: container_spec.name,
      deployment_id: container.deployment_id,
      image: container_spec.image,
      tag: container.tag,
      env_vars: Map.to_list(container_spec.env_vars),
      command: (container_spec.command && [container_spec.command]),
      args: container_spec.args,
      init_containers: prepare_init_containers(container_spec.init_container_specs),
      ports: prepare_container_ports(container),
      cpu_request: container_spec.cpu_request,
      cpu_limit: container_spec.cpu_limit,
      mem_request: container_spec.mem_request,
      mem_limit: container_spec.mem_limit
    }
  end

  defp prepare_init_containers(init_container_specs) do
    init_container_specs = Enum.sort_by(init_container_specs, &(&1.order))

    Enum.map(init_container_specs, fn init_container_spec ->
      %Dockup.Container{
        image: init_container_spec.image,
        tag: init_container_spec.tag,
        command: [init_container_spec.command],
        args: init_container_spec.args,
        env_vars: Map.to_list(init_container_spec.env_vars),
      }
    end)
  end

  defp prepare_container_ports(container) do
    ingresses = container.ingresses |> Repo.preload(:port_spec)
    Enum.map(ingresses, fn ingress ->
      %{
        port: ingress.port_spec.port,
        public: ingress.port_spec.public,
        host: ingress.endpoint
      }
    end)
  end
end
