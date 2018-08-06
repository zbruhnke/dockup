defmodule DockupUi.DeleteDeploymentServiceTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.{
    DeleteDeploymentService,
    Subdomain,
    Ingress,
    Repo
  }

  test "run returns {:ok, deployment}" do
    Application.put_env(:dockup_ui, :backend_module, Dockup.Backends.Fake)

    subdomain = insert(:subdomain)
    subdomain = Repo.preload(subdomain, [ingress: :container])
    {:ok, deployment} = DeleteDeploymentService.run(subdomain.ingress.container.deployment_id)

    nil = Repo.get(Ingress, subdomain.ingress.id)
    subdomain = Repo.get!(Subdomain, subdomain.id)

    %{ingress_id: nil} = subdomain
    %{status: "deleting"} = deployment
  end
end
