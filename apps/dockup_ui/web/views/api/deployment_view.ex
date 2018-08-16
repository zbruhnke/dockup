defmodule DockupUi.API.DeploymentView do
  use DockupUi.Web, :view

  alias DockupUi.Repo

  def render("index.json", %{deployments: deployments}) do
    %{data: render_many(deployments, DockupUi.API.DeploymentView, "deployment.json")}
  end

  def render("show.json", %{deployment: deployment}) do
    %{data: render_one(deployment, DockupUi.API.DeploymentView, "deployment.json")}
  end

  def render("deployment.json", %{deployment: deployment}) do
    deployment = Repo.preload(deployment, :blueprint)

    %{
      id: deployment.id,
      blueprint_name: deployment.blueprint.name,
      name: deployment.name,
      status: deployment.status,
      inserted_at: deployment.inserted_at,
      updated_at: deployment.updated_at,
      deployed_at: deployment.deployed_at
    }
  end

  def render("deployment_details.json", %{deployment: deployment}) do
    deployment = Repo.preload(deployment, [:blueprint, containers: [:container_spec, [ingresses: :port_spec]]])

    details = %{
      containers: Enum.map(deployment.containers, &(render("container.json", %{container: &1})))
    }

    "deployment.json"
    |> render(%{deployment: deployment})
    |> Map.merge(details)
  end

  def render("container.json", %{container: container}) do
    container = Repo.preload(container, [:container_spec, [ingresses: :port_spec]])
    endpoints = Enum.map(container.ingresses, fn ingress -> [ingress.endpoint, ingress.port_spec.port] end)

    %{
      id: container.id,
      status: container.status,
      status_reason: container.status_reason,
      name: container.container_spec.name,
      image: container.container_spec.image,
      tag: container.tag,
      endpoints: endpoints
    }
  end
end
