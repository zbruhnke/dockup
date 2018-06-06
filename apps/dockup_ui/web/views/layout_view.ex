defmodule DockupUi.LayoutView do
  use DockupUi.Web, :view

  def dockup_log_url do
    base_domain = Application.fetch_env!(:dockup, :base_domain)
    "//logio.#{base_domain}/#?projectName=dockup"
  end
end
