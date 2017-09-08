defmodule DockupUi.WhitelistedUrlTest do
  use DockupUi.ModelCase

  alias DockupUi.WhitelistedUrl

  @valid_attrs %{git_url: "some git_url"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, @invalid_attrs)
    refute changeset.valid?
  end
end
