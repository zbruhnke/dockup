defmodule DockupUi.API.DeploymentView do
  use DockupUi.Web, :view

  def render("index.json", %{deployments: deployments}) do
    %{data: render_many(deployments, DockupUi.API.DeploymentView, "deployment.json")}
  end

  def render("show.json", %{deployment: deployment}) do
    %{data: render_one(deployment, DockupUi.API.DeploymentView, "deployment.json")}
  end

  def render("deployment.json", %{deployment: deployment}) do
    %{
      id: deployment.id,
      git_url: deployment.git_url,
      branch: deployment.branch,
      status: deployment.status,
      log_url: deployment.log_url,
      urls: deployment.urls,
      updated_at: deployment.updated_at
    }
  end
end
