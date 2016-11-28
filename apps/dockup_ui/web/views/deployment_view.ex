defmodule DockupUi.DeploymentView do
  use DockupUi.Web, :view

  def service_urls_as_json(deployment) do
    raw Poison.encode!(deployment.service_urls)
  end
end
