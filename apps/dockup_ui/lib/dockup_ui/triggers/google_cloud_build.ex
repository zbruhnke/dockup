defmodule DockupUi.Triggers.GoogleCloudBuild do
  import Ecto.Query

  alias DockupUi.{
    Repo,
    AutoDeployment,
    ContainerSpec,
    DeployService
  }

  require Logger

  def handle(data) do
    %{"status" => status, "images" => images} =
      data
      |> Base.decode64!()
      |> Map.take(["status", "images"])

    if status == "SUCCESS" do
      Logger.info("Triggering auto deployment for images #{inspect images}")
      images
      |> Enum.map(& String.split(&1, ":"))
      |> Enum.each(fn [image, tag] -> trigger_auto_deployments(image, tag) end)
    end
  end


  def trigger_auto_deployments(image, tag) do
    blueprints_and_spec = get_deployables(image, tag)
    Enum.each(blueprints_and_spec, fn {blueprint_id, container_spec_id} ->
      deploy_blueprint(blueprint_id, container_spec_id, tag)
    end)
  end

  def get_deployables(image, tag) do
    tags = ["*", tag]
    query =
      from a in AutoDeployment,
      join: c in assoc(a, :container_spec),
      join: b in assoc(c, :blueprint),
      where: c.image == ^image,
      where: a.tag in ^tags,
      select: {b.id, c.id}

    Repo.all(query)
  end

  defp deploy_blueprint(blueprint_id, container_spec_id, tag) do
    query =
      from c in ContainerSpec,
      where: c.blueprint_id == ^blueprint_id,
      select: {c.id, c.default_tag}

    query
    |> Repo.all()
    |> prepare_deployment_params(container_spec_id, tag)
    |> DeployService.run()
  end

  defp prepare_deployment_params(query_result, container_spec_id, tag) do
    query_result
    |> Enum.map(fn
      {^container_spec_id, _} -> %{"id" => container_spec_id, "tag" => tag}
      {c_id, default_tag} -> %{"id" => c_id, "tag" => default_tag}
    end)
  end
end
