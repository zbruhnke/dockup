defmodule Dockup.Backends.Compose.DockerComposeConfigTest do
  use ExUnit.Case, async: true

  alias Dockup.{
    Backends.Compose.DockerComposeConfig
  }

  defp file_content do
    """
    foo:
      environment:
        - DOCKUP_EXPOSE_URL=true
    bar:
      environment:
        DOCKUP_EXPOSE_URL: 'true'
    """
  end

  test "rewrite_variables replaces dockup placeholder env variables with generated virtual hosts" do
    File.mkdir_p! Dockup.Project.project_dir("foo")
    config_file = DockerComposeConfig.compose_file("foo")
    File.write!(config_file, file_content())

    [url1, url2] = DockerComposeConfig.rewrite_variables("foo")

    assert url1 =~ ~r/[a-z]{10}.127.0.0.1.xip.io/
    assert url2 =~ ~r/[a-z]{10}.127.0.0.1.xip.io/

    content = File.read!(config_file)
    assert content,
      """
      foo:
        environment:
          - VIRTUAL_HOST=#{url1}
          - HTTPS_METHOD=noredirect
      bar:
        environment:
          VIRTUAL_HOST: #{url2}
          HTTPS_METHOD: noredirect
      """
  end
end
