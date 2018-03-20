defmodule DockupUi.LayoutView do
  use DockupUi.Web, :view

  def dockup_log_url do
    domain = Application.fetch_env!(:dockup, :domain)
    "//logio.#{domain}/#?projectName=dockup"
  end
end
