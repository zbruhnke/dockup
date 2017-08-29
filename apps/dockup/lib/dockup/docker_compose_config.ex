defmodule Dockup.DockerComposeConfig do
  require Logger

  alias Dockup.{
    Project
  }

  def rewrite_variables(project_id, project \\ Project) do
    Logger.info "Rewriting variables in docker-compose.yml of project #{project_id}"
    config_file = config_file(project_id)

    config =
      config_file
      |> File.stream!()
      |> Stream.map(& rewrite_virtual_host(&1, project) )
      |> Enum.join()

    File.write!(config_file, config)
  end

  def config_file(project_id) do
    Path.join(Dockup.Project.project_dir(project_id), "docker-compose.yml")
  end

  defp rewrite_virtual_host(str, project) do
    url = project.create_url()
    String.replace(str, ~r/DOCKUP_EXPOSE_URL(\s*.\s*)'?true'?/, "VIRTUAL_HOST\\1#{url}")
  end
end
