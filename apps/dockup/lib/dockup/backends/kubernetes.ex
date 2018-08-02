defmodule Dockup.Backends.Kubernetes do
  alias Dockup.Spec

  alias Kazan.Apis.Core.V1, as: CoreV1
  alias Kazan.Apis.Apps.V1, as: AppsV1
  alias Kazan.Apis.Extensions.V1beta1, as: V1beta1

  alias Kazan.Apis.Core.V1.{
    ContainerPort,
    PodSpec,
    Container,
    PodTemplateSpec,
    EnvVar,
    Service,
    ServiceSpec,
    ServicePort
  }

  alias Kazan.Apis.Apps.V1.{Deployment, DeploymentSpec}

  alias Kazan.Apis.Extensions.V1beta1.{
    Ingress,
    IngressSpec,
    IngressRule,
    HTTPIngressRuleValue,
    HTTPIngressPath,
    IngressBackend
  }

  alias Kazan.Models.Apimachinery.Meta.V1.{
    ObjectMeta,
    LabelSelector,
    DeleteOptions
  }

  require Logger

  @behaviour Spec

  @namespace "default"
  @name_prefix "dockup"

  def container_handle(container) do
    "#{@name_prefix}-#{container.deployment_id}-#{container.name}"
  end

  def container_handle(deployment_id, container_name) do
    "#{@name_prefix}-#{deployment_id}-#{container_name}"
  end

  @impl Spec
  def start(container) do
    container_handle = container_handle(container)

    {container, container_handle}
    |> create_deployment()
    |> create_service()
    |> create_ingress()

    {:ok, container_handle}
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
    container_handle
    |> delete_ingress()
    |> delete_service()
    |> delete_deployment()

    :ok
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
      "Unknown" -> "unknown"
      "Pending" -> "pending"
      "Running" -> "running"
      "Succeeded" -> "running"
      "Failed" -> "failed"
    end
  end

  def get_pods(container_handle) do
    response =
      @namespace
      |> CoreV1.list_namespaced_pod!(label_selector: "app=#{container_handle}")
      |> Kazan.run()

    case response do
      {:ok, %{items: pods}} ->
        pods

      {:error, error} ->
        Logger.error("Cannot get pods of deployment #{container_handle}: #{inspect(error)}")
        []
    end
  end

  ############## Helper functions to name resources ##########
  defp deployment_name(container_handle) do
    "#{container_handle}-deployment"
  end

  defp service_name(container_handle) do
    "#{container_handle}-service"
  end

  defp ingress_name(container_handle) do
    "#{container_handle}-ingress"
  end

  ############## Functions to create K8S resources ############
  defp create_deployment(args) do
    args
    |> prepare_deployment()
    |> AppsV1.create_namespaced_deployment!(@namespace)
    |> Kazan.run()
    |> handle_response()

    args
  end

  defp create_service(args) do
    args
    |> prepare_service()
    |> CoreV1.create_namespaced_service!(@namespace)
    |> Kazan.run()
    |> handle_response()

    args
  end

  defp create_ingress(args) do
    args
    |> prepare_ingress()
    |> V1beta1.create_namespaced_ingress!(@namespace)
    |> Kazan.run()
    |> handle_response()

    args
  end

  ############## Functions to delete K8S resources ############
  defp delete_ingress(container_handle) do
    %DeleteOptions{}
    |> V1beta1.delete_namespaced_ingress!(@namespace, ingress_name(container_handle))
    |> Kazan.run()
    |> handle_response()

    container_handle
  end

  defp delete_service(container_handle) do
    @namespace
    |> CoreV1.delete_namespaced_service!(service_name(container_handle))
    |> Kazan.run()
    |> handle_response()

    container_handle
  end

  defp delete_deployment(container_handle) do
    %DeleteOptions{}
    |> AppsV1.delete_namespaced_deployment!(@namespace, deployment_name(container_handle))
    |> Kazan.run()
    |> handle_response()

    container_handle
  end

  ############## Functions to prepare structs for K8S resources ############
  defp prepare_deployment({container, container_handle}) do
    %Deployment{
      metadata: %ObjectMeta{name: deployment_name(container_handle)},
      spec: %DeploymentSpec{
        selector: %LabelSelector{match_labels: %{app: container_handle}},
        template: %PodTemplateSpec{
          metadata: %ObjectMeta{
            labels: %{
              app: container_handle,
              deployment_id: Integer.to_string(container.deployment_id)
            }
          },
          spec: %PodSpec{
            containers: [
              %Container{
                name: container.name,
                image: get_image_name(container.image, container.tag),
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

  defp prepare_service({container, container_handle}) do
    %Service{
      metadata: %ObjectMeta{name: service_name(container_handle)},
      spec: %ServiceSpec{
        ports: get_service_ports(container.ports, container_handle),
        selector: %{app: container_handle}
      }
    }
  end

  defp prepare_ingress({container, container_handle}) do
    ingress_rules =
      container.ports
      |> Enum.filter(fn %{public: public, host: host} -> public && host end)
      |> Enum.map(&prepare_ingress_rule(container_handle, &1))

    %Ingress{
      metadata: %ObjectMeta{name: ingress_name(container_handle)},
      spec: %IngressSpec{rules: ingress_rules}
    }
  end

  defp prepare_ingress_rule(container_handle, %{port: port, host: host}) do

    %IngressRule{
      host: host,
      http: %HTTPIngressRuleValue{
        paths: [
          %HTTPIngressPath{
            backend: %IngressBackend{
              service_name: service_name(container_handle),
              service_port: port
            }
          }
        ]
      }
    }
  end

  # Just a wrapper that logs errors from K8S api responses
  # and returns :ok | :error
  defp handle_response(kazan_response) do
    case kazan_response do
      {:error, term} ->
        Logger.error("Error response: #{inspect(term)}")
        :error

      {:ok, _} ->
        :ok
    end
  end

  defp get_image_name(image, tag) do
    case tag do
      nil -> image
      tag -> "#{image}:#{tag}"
    end
  end

  defp get_container_ports(ports) do
    for %{port: port} <- ports do
      %ContainerPort{container_port: port}
    end
  end

  defp get_service_ports(ports, container_handle) do
    for %{port: port} <- ports do
      %ServicePort{port: port, name: "#{container_handle}-port-#{port}"}
    end
  end

  defp get_init_containers(containers, container_handle) do
    containers
    |> Enum.with_index()
    |> Enum.map(fn {container, index} ->
      name = "init-#{index + 1}-#{container_handle}"

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
    deployment = %Deployment{
      metadata: %ObjectMeta{name: deployment_name(container_handle)},
      spec: %DeploymentSpec{
        replicas: replicas
      }
    }

    deployment
    |> AppsV1.patch_namespaced_deployment!(@namespace, deployment_name(container_handle))
    |> Kazan.run()
    |> handle_response()
  end
end
