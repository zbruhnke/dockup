defmodule Dockup.WhitelistStoreTest do
  use ExUnit.Case, async: true

  alias Dockup.WhitelistStore

  @store_name :test_whitelist_store

  test "when file doesn't exist" do
    {:ok, _pid} = WhitelistStore.start_link(@store_name)
    refute WhitelistStore.whitelisted?("random", @store_name)
  end

  test "when file exists" do
    File.write!(WhitelistStore.whitelist_file, "foo\nbar")
    {:ok, _pid} = WhitelistStore.start_link(@store_name)
    assert WhitelistStore.whitelisted?("foo", @store_name)
    assert WhitelistStore.whitelisted?("bar", @store_name)
    refute WhitelistStore.whitelisted?("baz", @store_name)
    File.rm(WhitelistStore.whitelist_file)
  end
end

