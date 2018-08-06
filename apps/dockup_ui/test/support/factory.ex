defmodule DockupUi.Factory do
  alias DockupUi.{
    Deployment,
    Blueprint,
    Repo
  }

  def insert(model, args \\ [])

  def insert({:deployment, blueprint}, args) do
    deployment_factory(blueprint)
    |> Deployment.changeset(Map.new(args))
    |> Repo.insert!
  end

  def insert(:blueprint, args) do
    blueprint_factory()
    |> Blueprint.changeset(Map.new(args))
    |> Repo.insert!
  end

  defp deployment_factory(blueprint) do
    %Deployment{
      name: "dockup/master",
      status: "pending",
      blueprint_id: blueprint.id
    }
  end

  defp blueprint_factory do
    %Blueprint{
      name: "my-blueprint"
    }
  end
end
