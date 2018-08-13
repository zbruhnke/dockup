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
    container_spec = insert(:container_spec, %{env_vars: %{"FOO" => "prefix.${DOCKUP_ENDPOINT_4000}/login"}})
    insert(:container_spec, %{name: "bar", env_vars: %{"BAR" => "foo-${DOCKUP_SERVICE_#{container_spec.name}}-bar"}}, %{blueprint_id: container_spec.blueprint_id})
    insert(:port_spec, %{}, %{container_spec_id: container_spec.id})

    params = [
      %{"id" => container_spec.id, "tag" => "master"}
    ]

    {:ok, %{deployment: deployment, backend_containers: backend_containers}} = DockupUi.DeployService.run(params)
    deployment = Repo.get(Deployment, deployment.id)
    deployment = Repo.preload(deployment, [containers: [ingresses: :subdomain]])
    [%{tag: "master", handle: handle, ingresses: ingresses}, %{tag: "master", handle: _, ingresses: []}] = deployment.containers
    refute is_nil(handle)
    [%{endpoint: "foo.dockup.example.com", subdomain: %{subdomain: "foo"}}] = ingresses

    [{_, c1}, {_, c2}] = backend_containers
    assert c1.env_vars == [{"BAR", "foo-example.com-bar"}]
    assert c2.env_vars == [{"FOO", "prefix.foo.dockup.example.com/login"}]

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
