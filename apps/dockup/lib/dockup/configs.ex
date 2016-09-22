defmodule Dockup.Configs do
  require Logger
  import DefMemo

  defmemo workdir do
    (System.get_env("DOCKUP_WORKDIR") || Application.fetch_env!(:dockup, :workdir))
    |> ensure_dir_exists |> Path.expand
  end

  defmemo nginx_config_dir do
    (System.get_env("DOCKUP_NGINX_CONFIG_DIR") || Application.fetch_env!(:dockup, :nginx_config_dir))
    |> ensure_dir_exists |> Path.expand
  end

  defmemo cache_container do
    System.get_env("DOCKUP_CACHE_CONTAINER") || Application.fetch_env!(:dockup, :cache_container)
  end

  defmemo cache_volume do
    System.get_env("DOCKUP_CACHE_VOLUME") || Application.fetch_env!(:dockup, :cache_volume)
  end

  defmemo domain do
    System.get_env("DOCKUP_DOMAIN") || Application.fetch_env!(:dockup, :domain)
  end

  defmemo deployment_retention_days do
    (System.get_env("DOCKUP_DEPLOYMENT_RETENTION_DAYS") || Application.fetch_env!(:dockup, :deployment_retention_days))
    |> parse_as_integer
  end

  def whitelist_all? do
    env_var = System.get_env("DOCKUP_WHITELIST_ALL")
    if env_var do
      env_var == "true"
    else
      Application.fetch_env(:dockup, :whitelist_all) == {:ok, true}
    end
  end

  defp ensure_dir_exists(dir) do
    unless File.exists?(dir) do
      Logger.info "Creating missing directory: #{dir}"
      File.mkdir_p! dir
    end
    dir
  end

  defp parse_as_integer(value) do
    case is_integer(value) do
      true -> value
      false ->
        {value, _} = Integer.parse(value)
        value
    end
  end
end
