defmodule Dockup.Command do
  require Logger

  def run(command, args, dir) do
    {out, exit_status} = System.cmd(command, args, cd: dir)
    Logger.info "Output of command #{command} with args #{inspect args}: #{out}"
    {String.trim(out), exit_status}
  end
end
