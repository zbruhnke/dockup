defmodule DockupUi.LayoutView do
  use DockupUi.Web, :view

  def dockup_log_url do
    case Application.fetch_env!(:dockup_ui, :backend_module) do
      Dockup.Backends.Helm ->
        base_url = Application.fetch_env!(:dockup, :stackdriver_url)
        filter = "advancedFilter=resource.labels.container_name%3D%22dockup%22"
        base_url <> "&" <> filter
      _ ->
        base_domain = Application.fetch_env!(:dockup, :base_domain)
        "//logio.#{base_domain}/#?projectName=dockup"
    end
  end
end
