defmodule Dockup.Backends.Compose.Htpasswd do
  require Logger

  def write do
    case Application.fetch_env(:dockup, :htpasswd) do
      {:ok, htpasswd} ->
        base_domain = Application.fetch_env!(:dockup, :base_domain)
        logio_domain = "logio." <> base_domain
        htpasswd_dir = Application.fetch_env!(:dockup, :htpasswd_dir)

        for host <- ["ui." <> base_domain, logio_domain] do
          file = Path.join(htpasswd_dir, host)
          File.write!(file, htpasswd)
        end
      :error ->
        Logger.warn "htpasswd configuration is not set. Dockup will not have basic authentication."
    end
  end
end
