defmodule DockupUi.DeploymentView do
  use DockupUi.Web, :view

  def deployment_as_json(deployment) do
    raw Poison.encode!(deployment)
  end
end
