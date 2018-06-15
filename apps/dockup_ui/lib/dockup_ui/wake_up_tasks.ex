defmodule DockupUi.WakeUpTasks do
  require Ecto.Query

  def wake_up_all do
    {:ok, _} = Application.ensure_all_started(:dockup_ui)

    IO.inspect Application.started_applications

    DockupUi.Deployment
    |> Ecto.Query.where(status: "deployment_hibernated")
    |> DockupUi.Repo.all
    |> Enum.map(&wake_up/1)

    # 25 minutes
    :timer.sleep(25*60*1000)
    IO.inspect "stopping everything"
    :init.stop()
  end

  defp wake_up(deployment) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    backend.wake_up(deployment.id, fn (event, _payload) ->
      IO.inspect event
      repo = Application.get_env(:dockup_ui, :ecto_repos, []) |> List.first
      IO.inspect repo.start_link(pool_size: 1)

      status = Atom.to_string(event)
      changeset = DockupUi.Deployment.status_changeset(deployment, status)
      {:ok, _} = DockupUi.Repo.update(changeset)
    end)
  end
end
