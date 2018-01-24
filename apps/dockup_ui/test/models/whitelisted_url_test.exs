defmodule DockupUi.WhitelistedUrlTest do
  use DockupUi.ModelCase

  import DockupUi.Factory

  alias DockupUi.WhitelistedUrl

  test "changeset with valid attributes" do
    org = insert(:organization)
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, %{git_url: "foo", organization_id: org.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, %{})
    refute changeset.valid?
  end
end
