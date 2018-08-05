# To run this test, you need to include "integration" tag using "mix test --include integration"
# You also need to set an environment variable for this test to work:
# KUBECONFIG which points to your k8s config for a user who has cluster-admin rbac role.
defmodule Dockup.Backends.KubernetesTest do
  use ExUnit.Case, async: false

  alias Dockup.Backends.Kubernetes
  alias Dockup.Container

  @moduletag :integration
  @moduletag timeout: 200_000

  @deployment_id 1
  @container_name "helloworld"

  setup_all do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    container_handle = Kubernetes.container_handle(@deployment_id, @container_name)
    ensure_no_pods_are_running(container_handle)

    on_exit(fn ->
      Kubernetes.delete(container_handle)
    end)
  end

  test "K8S implementation of container interfaces" do
    container = %Container{
      name: @container_name,
      deployment_id: @deployment_id,
      image: "hashicorp/http-echo",
      tag: "0.2.3",
      env_vars: [
        {"FOO", "helloworld"}
      ],
      command: ["/http-echo"],
      args: ["-text=$(FOO)"],
      ports: [%{port: 5678, public: true, host: "echo.k8stest.c9s.tech"}],
      init_containers: [
        %Container{
          image: "busybox",
          command: ["sh"],
          args: ["-c", "echo Ran init container"]
        }
      ]
    }

    {:ok, container_handle} = Kubernetes.start(container)

    wait_for_deployment(container_handle, :running)

    [pod] = Kubernetes.get_pods(container_handle)
    %{spec: %{containers: [container]}} = pod
    assert [%{container_port: 5678, protocol: "TCP"}] = container.ports
    assert [%{name: "FOO", value: "helloworld"}] = container.env
    assert Kubernetes.logs(container_handle) =~ "Server is listening on :5678\n"

    url = String.to_charlist("https://echo.k8stest.c9s.tech")
    assert {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
             :httpc.request(:get, {url, []}, [], [])
    assert to_string(body) =~ "helloworld"

     assert :ok = Kubernetes.hibernate(container_handle)
     wait_for_deployment(container_handle, "unknown", 120)

     assert :ok = Kubernetes.wake_up(container_handle)
     wait_for_deployment(container_handle, "running")
  end

  defp wait_for_deployment(container_handle, expected_status) do
    wait_for_deployment(container_handle, expected_status, 30)
  end

  defp wait_for_deployment(_, _, 0) do
    flunk("Timed out when waiting for pod")
  end

  defp wait_for_deployment(container_handle, expected_status, i) do
    if Kubernetes.status(container_handle) != expected_status do
      :timer.sleep(1000)
      wait_for_deployment(container_handle, expected_status, i - 1)
    end
  end

  # This is to ensure pods are cleaned up before each run.
  # If the test errors with "invalidated", you may be running the test
  # immediately after a previous run. To avoid the error, just wait a couple of
  # minutes before running the test again, or change the value of @deployment_id
  # module attribute.
  def ensure_no_pods_are_running(deployment_name) do
    [] = Kubernetes.get_pods(deployment_name)
  end
end
