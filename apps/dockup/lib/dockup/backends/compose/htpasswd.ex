defmodule Dockup.Backends.Compose.Htpasswd do
  require Logger

  def write do
    case Application.fetch_env(:dockup, :htpasswd) do
      {:ok, htpasswd} ->
        domain = Application.fetch_env!(:dockup, :domain)
        logio_domain = "logio." <> domain
        htpasswd_dir = Application.fetch_env!(:dockup, :htpasswd_dir)

        for host <- [domain, logio_domain] do
          file = Path.join(htpasswd_dir, host)
          File.write!(file, htpasswd)
        end
      :error ->
        Logger.warn "htpasswd configuration is not set. Dockup will not have basic authentication."
    end
  end
end
