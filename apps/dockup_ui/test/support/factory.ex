defmodule DockupUi.Factory do
  alias DockupUi.{
    Deployment,
    WhitelistedUrl,
    Repo
  }

  def insert(model, args \\ [])

  def insert(:deployment, args) do
    deployment_factory()
    |> Deployment.changeset(Map.new(args))
    |> Repo.insert!
  end

  def insert(:whitelisted_url, args) do
    whitelisted_url_factory()
    |> WhitelistedUrl.changeset(Map.new(args))
    |> Repo.insert!
  end

  defp deployment_factory do
    %DockupUi.Deployment{
      git_url: "https://github.com/code-mancers/dockup.git",
      branch: "master",
      callback_url: "http://example.com/callback",
      status: "queued",
      log_url: "http://example.com/log_url",
    }
  end

  defp whitelisted_url_factory do
    %DockupUi.WhitelistedUrl{
      git_url: "https://github.com/code-mancers/dockup.git"
    }
  end
end
