defmodule DockupUi.Factory do
  alias DockupUi.{
    Deployment,
    Blueprint,
    Container,
    ContainerSpec,
    PortSpec,
    Ingress,
    Subdomain,
    Repo
  }

  def insert(model, args \\ %{}, data \\ %{})

  def insert(:subdomain, args, data) do
    ingress_id = data[:ingress_id] || insert(:ingress).id

    data =
      data
      |> Map.put(:ingress_id, ingress_id)

    subdomain_factory(data)
    |> Subdomain.changeset(args)
    |> Repo.insert!
  end

  def insert(:port_spec, args, data) do
    container_spec_id = data[:container_spec_id] || insert(:container_spec).id

    data =
      data
      |> Map.put(:container_spec_id, container_spec_id)

    port_spec_factory(data)
    |> PortSpec.changeset(args)
    |> Repo.insert!
  end

  def insert(:ingress, args, data) do
    port_spec_id = data[:port_spec_id] || insert(:port_spec).id
    port_spec = Repo.get!(PortSpec, port_spec_id)
    container = insert(:container, %{}, %{container_spec_id: port_spec.container_spec_id})

    data =
      data
      |> Map.put(:container_id, container.id)
      |> Map.put(:port_spec_id, port_spec_id)

    ingress_factory(data)
    |> Ingress.changeset(args)
    |> Repo.insert!
  end

  def insert(:container, args, data) do
    container_spec_id = data[:container_spec_id] || insert(:container_spec).id
    container_spec = Repo.get!(ContainerSpec, container_spec_id)
    blueprint = Repo.get!(Blueprint, container_spec.blueprint_id)
    deployment_id = data[:deployment_id] || insert(:deployment, %{}, %{blueprint_id: blueprint.id}).id

    data =
      data
      |> Map.put(:container_spec_id, container_spec_id)
      |> Map.put(:deployment_id, deployment_id)

    container_factory(data)
    |> Container.changeset(args)
    |> Repo.insert!
  end

  def insert(:container_spec, args, data) do
    blueprint_id = data[:blueprint_id] || insert(:blueprint).id

    data =
      data
      |> Map.put(:blueprint_id, blueprint_id)

    container_spec_factory(data)
    |> ContainerSpec.changeset(args)
    |> Repo.insert!
  end

  def insert(:deployment, args, data) do
    blueprint_id = data[:blueprint_id] || insert(:blueprint).id
    data = Map.put(data, :blueprint_id, blueprint_id)

    deployment_factory(data)
    |> Deployment.changeset(args)
    |> Repo.insert!
  end

  def insert(:blueprint, args, data) do
    blueprint_factory(data)
    |> Blueprint.changeset(args)
    |> Repo.insert!
  end

  defp deployment_factory(data) do
    %Deployment{
      name: "dockup/master",
      status: "pending",
    } |> Map.merge(data)
  end

  defp blueprint_factory(data) do
    %Blueprint{
      name: "my-blueprint"
    } |> Map.merge(data)
  end

  defp container_factory(data) do
    %Container{
      handle: "frontend-handle",
      status: "running",
      tag: "master"
    } |> Map.merge(data)
  end

  defp container_spec_factory(data) do
    %ContainerSpec{
      name: "frontend",
      image: "image",
      default_tag: "master"
    } |> Map.merge(data)
  end

  defp port_spec_factory(data) do
    %PortSpec{
      port: 4000,
      public: true
    } |> Map.merge(data)
  end

  defp ingress_factory(data) do
    %Ingress{
      endpoint: "foo.company.com"
    } |> Map.merge(data)
  end

  defp subdomain_factory(data) do
    %Subdomain{
      subdomain: "foo"
    } |> Map.merge(data)
  end
end
