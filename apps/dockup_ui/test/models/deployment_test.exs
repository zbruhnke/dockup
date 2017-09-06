defmodule DockupUi.DeploymentTest do
  use DockupUi.ModelCase

  alias DockupUi.Deployment

  @valid_attrs %{git_url: "foo", branch: "bar", callback_url: "baz"}

  test "changeset with valid attributes" do
    changeset = Deployment.changeset(%Deployment{}, @valid_attrs)
    assert changeset.valid?
  end
end
