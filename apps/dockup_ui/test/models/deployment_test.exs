defmodule DockupUi.DeploymentTest do
  use DockupUi.ModelCase

  alias DockupUi.Deployment
  import DockupUi.Factory

  test "changeset with valid attributes" do
    blueprint = insert(:blueprint)
    changeset = Deployment.changeset(%Deployment{blueprint_id: blueprint.id}, %{name: "foo", status: "queued"})
    assert changeset.valid?
  end
end
