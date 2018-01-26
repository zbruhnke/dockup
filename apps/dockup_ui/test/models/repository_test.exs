defmodule DockupUi.RepositoryTest do
  use DockupUi.ModelCase

  import DockupUi.Factory

  alias DockupUi.Repository

  test "changeset with valid attributes" do
    org = insert(:organization)
    changeset = Repository.changeset(%Repository{}, %{git_url: "foo", organization_id: org.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Repository.changeset(%Repository{}, %{})
    refute changeset.valid?
  end
end
