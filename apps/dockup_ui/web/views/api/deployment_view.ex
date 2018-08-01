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
      updated_at: deployment.updated_at
    }
  end
end
