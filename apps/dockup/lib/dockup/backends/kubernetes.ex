defmodule Dockup.Backends.Kubernetes do
  alias Dockup.Spec

  alias Kazan.Apis.Core.V1, as: CoreV1
  alias Kazan.Apis.Apps.V1, as: AppsV1
  alias Kazan.Apis.Core.V1.{ContainerPort, PodSpec, Container, PodTemplateSpec, EnvVar}
  alias Kazan.Apis.Apps.V1.{Deployment, DeploymentSpec}

  alias Kazan.Models.Apimachinery.Meta.V1.{
    ObjectMeta,
    LabelSelector,
    DeleteOptions
  }

  require Logger

  @behaviour Spec

  @namespace "default"

  @impl Spec
  def start(container) do
    container_handle = deployment_name(container.deployment_id, container.name)

    container
    |> prepare_deployment()
    |> AppsV1.create_namespaced_deployment!(@namespace)
    |> Kazan.run()
    |> handle_response()
    |> format_response(container_handle)
  end

  @impl Spec
  def hibernate(container_handle) do
    scale(container_handle, 0)
  end

  @impl Spec
  def wake_up(container_handle) do
    scale(container_handle, 1)
  end

  @impl Spec
  def delete(container_handle) do
    %DeleteOptions{}
    |> AppsV1.delete_namespaced_deployment!(@namespace, container_handle)
    |> Kazan.run()
    |> handle_response()
  end

  # Very basic logging for now
  @impl Spec
  def logs(container_handle) do
    pods = get_pods(container_handle)

    case pods do
      [] ->
        ""
      [%{metadata: %{name: name}}] ->
        @namespace
        |> CoreV1.read_namespaced_pod_log!(name)
        |> Kazan.run!()
    end
  end

  @impl Spec
  def status(container_handle) do
    pods = get_pods(container_handle)

    pod_status =
      case pods do
        [] -> "Unknown"
        [%{status: status}] -> status.phase
      end

    case pod_status do
      "Unknown" -> :unknown
      "Pending" -> :pending
      "Running" -> :running
      "Succeeded" -> :running
      "Failed" -> :failed
    end
  end

  def get_pods(container_handle) do
    response =
      @namespace
      |> CoreV1.list_namespaced_pod!(label_selector: "deployment_name=#{container_handle}")
      |> Kazan.run()

    case response do
      {:ok, %{items: pods}} ->
        pods
      {:error, error} ->
        Logger.error("Cannot get pods of deployment #{container_handle}: #{inspect error}")
        []
    end
  end

  def deployment_name(deployment_id, container_name) do
     "#{deployment_id}-#{container_name}-deployment"
  end

  defp prepare_deployment(container) do
    deployment_name = deployment_name(container.deployment_id, container.name)
    pod_label = "#{container.deployment_id}-#{container.name}"
    image_name = get_image_name(container.image, container.tag)

    %Deployment{
      metadata: %ObjectMeta{name: deployment_name},
      spec: %DeploymentSpec{
        selector: %LabelSelector{match_labels: %{app: pod_label}},
        template: %PodTemplateSpec{
          metadata: %ObjectMeta{
            labels: %{
              app: pod_label,
              deployment_id: Integer.to_string(container.deployment_id),
              deployment_name: deployment_name,
            }
          },
          spec: %PodSpec{
            containers: [
              %Container{
                name: container.name,
                image: image_name,
                ports: get_container_ports(container.ports),
                command: container.command,
                args: container.args,
                env: get_env(container.env_vars)
              }
            ],
            init_containers: get_init_containers(container.init_containers, container.name)
          }
        }
      }
    }
  end

  defp get_image_name(image, tag) do
    case tag do
      nil -> image
      tag -> "#{image}:#{tag}"
    end
  end

  defp get_container_ports(ports) do
    for port <- ports do
      %ContainerPort{container_port: port}
    end
  end

  defp get_init_containers(containers, container_name) do
    containers
    |> Enum.with_index()
    |> Enum.map(fn {container, index} ->
      name = "init-#{index + 1}-#{container_name}"
      %Container{
        name: name,
        image: get_image_name(container.image, container.tag),
        command: container.command,
        args: container.args,
        env: get_env(container.env_vars)
      }
    end)
  end

  defp get_env(env_vars) do
    for {name, value} <- env_vars do
      %EnvVar{name: name, value: value}
    end
  end

  defp scale(container_handle, replicas) do
    deployment =
      %Deployment{
        metadata: %ObjectMeta{name: container_handle},
        spec: %DeploymentSpec{
          replicas: replicas
        }
      }

    deployment
    |> AppsV1.patch_namespaced_deployment!(@namespace, container_handle)
    |> Kazan.run()
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, _} -> :ok
      {:error, error} ->
        Logger.error("Error response: #{inspect error}")
        :error
    end
  end

  defp format_response(response, container_handle) do
    case response do
      :ok -> {:ok, container_handle}
      :error -> :error
    end
  end
end
