defmodule DeployServiceTest do
  use DockupUi.ModelCase, async: true

  import DockupUi.Factory

  alias DockupUi.{
    Repo,
    Deployment
  }

  test "run returns {:ok, multi_changes} if deployment is saved and the job is scheduled" do
    Application.put_env(:dockup_ui, :backend_module, Dockup.Backends.Fake)
    Application.put_env(:dockup_ui, :base_domain, "dockup.example.com")

    # Reserve an empty subdomain
    insert(:subdomain, %{subdomain: "foo"}, %{ingress_id: nil})
    port_spec = insert(:port_spec)
    port_spec = Repo.preload(port_spec, :container_spec)
    params = [
      %{"id" => port_spec.container_spec.id, "name" => port_spec.container_spec.name, "tag" => "master"}
    ]

    {:ok, %{deployment: deployment}} = DockupUi.DeployService.run(params)
    deployment = Repo.get(Deployment, deployment.id)
    deployment = Repo.preload(deployment, [containers: [ingresses: :subdomain]])
    [%{tag: "master", handle: handle, ingresses: ingresses}] = deployment.containers
    refute is_nil(handle)
    [%{endpoint: "foo.dockup.example.com", subdomain: %{subdomain: "foo"}}] = ingresses
    wait_for_container_status(handle, "running")
  end

  #TODO: Add tests for negative cases to ensure proper error messages are sent to client


  defp wait_for_container_status(container_handle, expected_status) do
    wait_for_container_status(container_handle, expected_status, 30)
  end
  defp wait_for_container_status(_, _, 0) do
    flunk("Timed out when waiting for container to run")
  end
  defp wait_for_container_status(container_handle, expected_status, i) do
    if Dockup.Backends.Fake.status(container_handle) != expected_status do
      :timer.sleep(1000)
      wait_for_container_status(container_handle, expected_status, i - 1)
    end
  end
end
