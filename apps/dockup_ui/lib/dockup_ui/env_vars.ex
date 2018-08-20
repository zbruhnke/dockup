defmodule DockupUi.EnvVars do
  @doc """
  Thisinterpolates dockup variables in environment variables
  configured for containers. Supported dockup variables are:

  DOCKUP_SERVICE_<container name> - gets replaced by the hostname of a service
  which is part of this deployment.
  DOCKUP_ENDPOINT_<container_name>_<port> - gets replaced by the ingress endpoint
  of given port of a container.
  """
  def interpolate_dockup_variables(containers) do
    Enum.map(containers, fn container ->
      %{
        container
        | env_vars: rewrite_variables(container.env_vars, container.deployment_id, containers),
          init_containers:
            interpolate_dockup_variables(container.init_containers, container.deployment_id, containers)
      }
    end)
  end
  def interpolate_dockup_variables(init_containers, deployment_id, containers) do
    Enum.map(init_containers, fn container ->
      %{container | env_vars: rewrite_variables(container.env_vars, deployment_id, containers)}
    end)
  end

  defp rewrite_variables(env_vars, deployment_id, containers) do
    Enum.map(env_vars, fn {key, value} ->
      value =
        cond do
          String.match?(value, ~r/\${DOCKUP_SERVICE_.*}/) ->
            replace_container_hostname(value, deployment_id)
          String.match?(value, ~r/\${DOCKUP_ENDPOINT_.*}/) ->
            replace_ingress_hostname(value, containers)
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

  defp replace_ingress_hostname(value, containers) do
    {container_name, target_port} =
      case Regex.named_captures(~r/\${DOCKUP_ENDPOINT_(?<container_name>.+)_(?<port>\d+)}/, value) do
        nil -> raise "Environment variable value #{value} cannot be replaced with an endpoint. It should be of the format DOCKUP_ENDPOINT_<container_name>_<port>"
        %{"port" => port, "container_name" => container_name} -> {container_name, String.to_integer(port)}
      end

    replace_string =
      Enum.find_value(containers, fn
        %{name: ^container_name, ports: ports} ->
          Enum.find_value(ports, fn
            %{port: ^target_port, host: host} -> host
            _ -> nil
          end)
        _ -> nil
      end)

    Regex.replace(~r/\${DOCKUP_ENDPOINT_.*}/, value, replace_string)
  end
end
