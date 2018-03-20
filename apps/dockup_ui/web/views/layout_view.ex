defmodule DockupUi.LayoutView do
  use DockupUi.Web, :view

  def log_path do
    domain = Application.fetch_env!(:dockup, :domain)
    "//logio.#{domain}/#?projectName=dockup"
  end
end
