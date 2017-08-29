defmodule Dockup.DockerComposeConfigTest do
  use ExUnit.Case, async: true

  alias Dockup.{
    DockerComposeConfig
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
    config_file = DockerComposeConfig.config_file("foo")
    File.write!(config_file, file_content())

    DockerComposeConfig.rewrite_variables("foo")

    content = File.read!(config_file)
    assert content =~
      ~r"""
      foo:
        environment:
          - VIRTUAL_HOST=[a-z]{10}.127.0.0.1.xip.io
      bar:
        environment:
          VIRTUAL_HOST: [a-z]{10}.127.0.0.1.xip.io
      """
  end
end
