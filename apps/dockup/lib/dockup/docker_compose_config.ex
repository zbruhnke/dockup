defmodule Dockup.DockerComposeConfig do
  require Logger

  alias Dockup.{
    Project
  }

  def rewrite_variables(project_id, project \\ Project) do
    Logger.info "Rewriting variables in docker-compose.yml of project #{project_id}"
    config_file = config_file(project_id)

    config_file
    |> File.stream!()
    |> Stream.map(& rewrite_virtual_host(&1, project) )
    |> write_file(config_file)
  end

  def config_file(project_id) do
    Path.join(Dockup.Project.project_dir(project_id), "docker-compose.yml")
  end

  defp rewrite_virtual_host(str, project) do
    if String.match?(str, ~r/DOCKUP_EXPOSE_URL/) do
      url = project.create_url()
      replaced_string = String.replace(str, ~r/DOCKUP_EXPOSE_URL(\s*.\s*)'?true'?/, "VIRTUAL_HOST\\1#{url}")
      {url, replaced_string}
    else
      {nil, str}
    end
  end

  defp write_file(urls_and_content, config_file) do
    {urls, content} =
      Enum.reduce(urls_and_content, {[], ""}, fn {url, string}, {urls, content} ->
        if url do
          {[url | urls], content <> string}
        else
          {urls, content <> string}
        end
      end)

    File.write!(config_file, content)

    Enum.reverse(urls)
  end
end
