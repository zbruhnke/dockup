defmodule Dockup.Backends.Compose.Netrc do
  require Logger

  def write do
    case Application.fetch_env(:dockup, :github_oauth_token) do
      {:ok, token} ->
        file = Path.join(System.user_home!(), ".netrc")
        content = "machine github.com login #{token} password"
        File.write!(file, content)
      :error ->
        Logger.warn "Github OAuth token not configured. Dockup cannot clone private repositories."
    end
  end
end
