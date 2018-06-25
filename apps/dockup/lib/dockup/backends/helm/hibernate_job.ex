defmodule Dockup.Backends.Helm.HibernateJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Command
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(deployment_id, callback \\ DefaultCallback) do
    project_id = to_string(deployment_id)
    name = "dockup#{project_id}"

    {deploys, 0} =
      Command.run("kubectl",
        ["get", "deploy", "-l", "release=#{name}", "-o", "name"],
        ".")

    deploys
    |> String.split("\n")
    |> Enum.map(&hibernate_deploy/1)

    callback.update_status(deployment_id, "hibernated")
  end

  defp hibernate_deploy(deploy) do
    Dockup.Command.run("kubectl",
      ["patch", deploy, "-p", "{\"spec\":{\"replicas\":0}}"],
      ".")
  end
end
