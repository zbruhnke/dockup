defmodule Dockup.Config do
  require Logger

  def set_configs_from_env do
    for {env_var, config_key, type} <- configs() do
      set_config(System.get_env(env_var), config_key, type)
    end
  end

  defp configs do
    [
      {"DOCKUP_WORKDIR", :workdir, :directory},
      {"DOCKUP_DOMAIN", :domain, :string},
      {"DOCKUP_DEPLOYMENT_RETENTION_DAYS", :deployment_retention_days, :integer},
      {"DOCKUP_HTPASSWD_DIR", :htpasswd_dir, :directory},
      {"DOCKUP_HTPASSWD", :htpasswd, :string},
      {"DOCKUP_GITHUB_OAUTH_TOKEN", :github_oauth_token, :string},
    ]
  end

  defp set_config(nil, _, _) do
    # Do nothing if env var is not set
  end

  defp set_config(env_val, config_key, :directory) do
    Application.put_env(:dockup, config_key, env_val)
  end

  defp set_config(env_val, config_key, :string) do
    Application.put_env(:dockup, config_key, env_val)
  end

  defp set_config(env_val, config_key, :integer) do
    integer = parse_as_integer(env_val)
    Application.put_env(:dockup, config_key, integer)
  end

  defp ensure_dir_exists(dir) do
    unless File.exists?(dir) do
      Logger.info "Creating missing directory: #{dir}"
      File.mkdir_p! dir
    end
    dir
  end

  defp parse_as_integer(value) do
    if is_integer(value) do
      value
    else
      {value, _} = Integer.parse(value)
      value
    end
  end
end
