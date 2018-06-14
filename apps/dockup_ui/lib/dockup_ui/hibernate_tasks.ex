defmodule DockupUi.HibernateTasks do
  require Ecto.Query

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :dockup_ui
  ]

  def hibernate_all do
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    deployed_deployments =
      DockupUi.Deployment
      |> Ecto.Query.where(status: "started")
      |> DockupUi.Repo.all

    ids = Enum.map(deployed_deployments, fn i -> i.id end)
    DockupUi.HibernateDeploymentService.run_all(ids)
  end
end
