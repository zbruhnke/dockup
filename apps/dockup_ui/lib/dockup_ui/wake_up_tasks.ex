defmodule DockupUi.WakeUpTasks do
  require Ecto.Query

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :dockup_ui
  ]

  def wake_up_all do
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    deployed_deployments =
      DockupUi.Deployment
      |> Ecto.Query.where(status: "deployment_hibernated")
      |> DockupUi.Repo.all

    ids = Enum.map(deployed_deployments, fn i -> i.id end)
    DockupUi.WakeUpDeploymentService.run_all(ids)
  end
end
