defmodule DockupUi.HibernateTasks do
  require Ecto.Query

  def hibernate_all do
    {:ok, _} = Application.ensure_all_started(:dockup_ui)

    IO.inspect Application.started_applications

    statuses = ["started", "hibernating_deployment"]
    DockupUi.Deployment
    |> Ecto.Query.where([d], d.status in ^statuses)
    |> DockupUi.Repo.all
    |> Enum.map(&hibernate/1)

    :timer.sleep(50000)
    IO.inspect "stopping everything"
    :init.stop()
  end

  defp hibernate(deployment) do
    backend = Application.fetch_env!(:dockup_ui, :backend_module)
    backend.hibernate(deployment.id, fn (event, _payload) ->
      IO.inspect event
      repo = Application.get_env(:dockup_ui, :ecto_repos, []) |> List.first
      IO.inspect repo.start_link(pool_size: 1)

      status = Atom.to_string(event)
      changeset = DockupUi.Deployment.status_changeset(deployment, status)
      {:ok, _} = DockupUi.Repo.update(changeset)
    end)
  end
end
