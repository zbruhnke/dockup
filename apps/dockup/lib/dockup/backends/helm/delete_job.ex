defmodule Dockup.Backends.Helm.DeleteJob do
  require Logger

  alias Dockup.{
    DefaultCallback,
    Project,
    Command
  }

  def spawn_process(id, callback) do
    spawn(fn -> perform(id, callback) end)
  end

  def perform(deployment_id, callback \\ DefaultCallback, deps \\ []) do
    project = deps[:project] || Project
    project_id = to_string(deployment_id)
    name = "dockup#{project_id}"

    case Command.run("helm", ["delete", name], ".") do
      {_, 0} ->
        Logger.info("deleted #{name} successfully")
      {error_msg, 1} ->
        msg = "Error: release: \"#{name}\" not found"
        if error_msg == msg do
          Logger.info("helm: #{name} not found, its okay")
        else
          Logger.info(error_msg)
        end
    end
    project.delete_repository(project_id)

    callback.update_status(deployment_id, "deleted")
  end
end
