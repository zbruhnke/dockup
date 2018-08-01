defmodule DockupUi.BackendAdapter do
  alias DockupUi.{
    Repo,
    Container,
    ContainerSpec
  }

  def prepare_containers(deployment) do
    deployment = Repo.preload(deployment, [containers: [container_spec: [:init_container_specs, port_specs: [ingress: :subdomain]]]])

    containers =
      Enum.map(deployment.containers, fn container ->
        container_spec = container.container_spec
        %Dockup.Container{
          name: container_spec.name,
          deployment_id: deployment.id,
          image: container_spec.image,
          tag: container.tag,
          env_vars: Map.to_list(container_spec.env_vars),
          command: (container_spec.command && [container_spec.command]),
          args: container_spec.args,
          init_containers: prepare_init_containers(container_spec.init_container_specs),
          ports: prepare_container_ports(container_spec.port_specs)
        }
      end)
  end

  defp prepare_init_containers(init_container_specs) do
    init_container_specs = Enum.sort_by(init_container_specs, &(&1[:order]))

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

  defp prepare_container_ports(port_specs) do
    Enum.map(port_specs, fn port_spec ->
      %{
        port: port_spec.port,
        public: port_spec.public,
        host: (port_spec.ingress && port_spec.ingress.endpoint)
      }
    end)
  end
end
