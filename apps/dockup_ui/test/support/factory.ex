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

  defp deployment_factory do
    %DockupUi.Deployment{
      name: "dockup/master",
      status: "pending"
    }
  end
end
