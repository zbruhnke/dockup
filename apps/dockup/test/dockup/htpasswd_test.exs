defmodule Dockup.HtpasswdTest do
  use ExUnit.Case, async: true

  test "write() writes htpasswd string into both dockup and logio host files" do
    Application.put_env(:dockup, :htpasswd, "foo:bar")
    Application.fetch_env!(:dockup, :htpasswd_dir) |> File.mkdir_p!()

    Dockup.Htpasswd.write()

    htpasswd_dir = Application.fetch_env!(:dockup, :htpasswd_dir)
    dockup_host = Path.join(htpasswd_dir, "127.0.0.1.xip.io")
    logio_host = Path.join(htpasswd_dir, "logio.127.0.0.1.xip.io")
    assert File.read!(dockup_host), "foo:bar"
    assert File.read!(logio_host), "foo:bar"
  end
end

