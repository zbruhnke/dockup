defmodule DockupUi.BackendAdapter do
  alias DockupUi.Repo

  def prepare_containers(deployment) do
    deployment = Repo.preload(deployment, [containers: [container_spec: [:init_container_specs, port_specs: [ingress: :subdomain]]]])

    Enum.map(deployment.containers, &prepare_container/1)
  end

  def prepare_container(container) do
    container_spec = container.container_spec
    ports = prepare_container_ports(container_spec.port_specs)
    env_vars = prepare_env_vars(container_spec.env_vars, ports, container.deployment_id)

    %Dockup.Container{
      name: container_spec.name,
      deployment_id: container.deployment_id,
      image: container_spec.image,
      tag: container.tag,
      env_vars: env_vars,
      command: (container_spec.command && [container_spec.command]),
      args: container_spec.args,
      init_containers: prepare_init_containers(container_spec.init_container_specs),
      ports: prepare_container_ports(container_spec.port_specs)
    }
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

  defp prepare_env_vars(env_vars, ports, deployment_id) do
    Enum.map(env_vars, fn {key, value} ->
      value =
        cond do
          String.match?(value, ~r/\${DOCKUP_SERVICE_.*}/) ->
            replace_container_hostname(value, deployment_id)
          String.match?(value, ~r/\${DOCKUP_ENDPOINT_.*}/) ->
            replace_ingress_hostname(value, ports)
          true ->
            value
        end

      {key, value}
    end)
  end

  defp replace_container_hostname(value, deployment_id) do
    container_name =
      case Regex.named_captures(~r/\${DOCKUP_SERVICE_(?<container_name>.+)}/, value) do
        nil -> raise "Environment variable value #{value} cannot be replaced with a serice hostname. It should be of the format DOCKUP_SERVICE_<container name>"
        %{"container_name" => container_name} -> container_name
      end

    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    replace_string = backend.hostname(deployment_id, container_name)

    Regex.replace(~r/\${DOCKUP_SERVICE_.+}/, value, replace_string)
  end

  defp replace_ingress_hostname(value, ports) do
    target_port =
      case Regex.named_captures(~r/\${DOCKUP_ENDPOINT_(?<port>\d+)}/, value) do
        nil -> raise "Environment variable value #{value} cannot be replaced with an endpoint. It should be of the format DOCKUP_ENDPOINT_<port>"
        %{"port" => port} -> String.to_integer(port)
      end

    replace_string =
      Enum.find_value(ports, fn %{port: port, host: host} ->
        if port == target_port do
          host
        end
      end)

    Regex.replace(~r/\${DOCKUP_ENDPOINT_.*}/, value, replace_string)
  end
end
