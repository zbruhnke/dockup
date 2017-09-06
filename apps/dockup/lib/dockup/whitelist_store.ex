defmodule Dockup.WhitelistStore do
  require Logger
  @moduledoc """
  This module is responsible for loading a list of whitelisted git urls
  from a file and providing functions to check if a URL is whitelisted or not.
  """

  def start_link(name \\ __MODULE__, urls) do
    Logger.info "Whitelisted Git URLs: #{inspect urls}"
    Agent.start_link(fn -> urls end, name: name)
  end

  @doc """
  Returns true if git url is whitelisted
  """
  def whitelisted?(git_url, name \\ __MODULE__) do
    whitelisted_url?(git_url, name)
  end

  defp whitelisted_url?(git_url, name) do
    if Process.whereis(name) do
      Agent.get(name, fn urls -> git_url in urls end)
    else
      Logger.error "WhitelistStore agent is not running."
      false
    end
  end
end
