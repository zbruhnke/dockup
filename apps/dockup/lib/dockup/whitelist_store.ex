defmodule Dockup.WhitelistStore do
  require Logger
  @moduledoc """
  This module is responsible for loading a list of whitelisted git urls
  from a file and providing functions to check if a URL is whitelisted or not.
  """

  def start_link(name \\ __MODULE__) do
    Agent.start_link(__MODULE__, :get_urls, [], name: name)
  end

  @doc """
  Returns true if git url is whitelisted
  """
  def whitelisted?(git_url, name \\ __MODULE__) do
    Dockup.Configs.whitelist_all? || whitelisted_url?(git_url, name)
  end

  def whitelist_file do
    Path.join(Dockup.Configs.workdir, "whitelisted_urls")
  end

  def get_urls do
    urls =
      whitelist_file
      |> File.read!
      |> String.split
    Logger.info "Whitelisted Git URLs: #{inspect urls}"
    urls
  rescue
    _e ->
      Logger.warn "Cannot load #{whitelist_file}"
      []
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
