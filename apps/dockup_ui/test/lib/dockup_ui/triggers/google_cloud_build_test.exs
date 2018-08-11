defmodule GoogleCloudBuildTest do
  use DockupUi.ModelCase, async: true

  import DockupUi.Factory

  alias DockupUi.{
    Triggers.GoogleCloudBuild,
    Deployment
  }

  test "get_deployables" do
    cs1 = insert(:container_spec, %{image: "foo"})
    cs2 = insert(:container_spec, %{image: "bar"}, %{blueprint_id: cs1.blueprint_id})
    insert(:auto_deployment, %{tag: "*"}, %{container_spec_id: cs2.id})
    insert(:auto_deployment, %{tag: "other-feature"}, %{container_spec_id: cs1.id})

    assert [{cs2.blueprint_id, cs2.id}]  == GoogleCloudBuild.get_deployables("bar", "my-feature")
    assert [{cs1.blueprint_id, cs1.id}]  == GoogleCloudBuild.get_deployables("foo", "other-feature")
    assert []  == GoogleCloudBuild.get_deployables("foo", "my-feature")
  end

  test "handle" do
    Application.put_env(:dockup_ui, :backend_module, Dockup.Backends.Fake)

    cs1 = insert(:container_spec, %{image: "foo"})
    cs2 = insert(:container_spec, %{image: "bar"}, %{blueprint_id: cs1.blueprint_id})
    insert(:auto_deployment, %{tag: "*"}, %{container_spec_id: cs2.id})
    insert(:auto_deployment, %{tag: "other-feature"}, %{container_spec_id: cs1.id})

    GoogleCloudBuild.trigger_auto_deployments("bar", "new-feature")

    deployment = Repo.one!(Deployment)
    deployment = Repo.preload(deployment, :containers)
    assert [%{tag: "new-feature", container_spec_id: cs2_id}, %{tag: "master", container_spec_id: cs1_id}] = deployment.containers
    assert cs2_id == cs2.id
    assert cs1_id == cs1.id
  end
end
