defmodule Dockup.WhitelistStoreTest do
  use ExUnit.Case, async: true

  alias Dockup.WhitelistStore

  @store_name :test_whitelist_store

  test "when store not started" do
    refute WhitelistStore.whitelisted?("random", @store_name)
  end

  test "when store started" do
    {:ok, _pid} = WhitelistStore.start_link(@store_name, ["foo", "bar"])
    assert WhitelistStore.whitelisted?("foo", @store_name)
    assert WhitelistStore.whitelisted?("bar", @store_name)
    refute WhitelistStore.whitelisted?("baz", @store_name)
  end
end

