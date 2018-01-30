defmodule DockupUi.DeploymentView do
  use DockupUi.Web, :view

  def deployment_as_json(deployment) do
    DockupUi.API.DeploymentView.render("deployment.json", %{deployment: deployment})
    |> Poison.encode!()
    |> raw()
  end
end
