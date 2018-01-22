defmodule DockupUi.Config do
  @moduledoc """
  This module makes it easy to override application configs (found in config/config.exs)
  using environment variables. `set_configs_from_env()` is called when
  the application starts up.
  """

  def set_configs_from_env do
    for {env_var, config_key} <- configs() do
      set_config(System.get_env(env_var), config_key)
    end
  end

  # List of environment variables and the application configs that they will override
  defp configs do
    [
      {"GOOGLE_CLIENT_ID", {:ueberauth, Ueberauth.Strategy.Google.OAuth, :client_id}},
      {"GOOGLE_CLIENT_SECRET", {:ueberauth, Ueberauth.Strategy.Google.OAuth, :client_secret}}
    ]
  end

  defp set_config(nil, _) do
    # Do nothing if env var is not set
  end

  defp set_config(env_val, {app, key1, key2}) do
    app
    |> Application.get_env(key1, %{})
    |> Keyword.put(key2, env_val)
    |> set_config(key1, app)
  end

  defp set_config(env_val, {key1, key2}) do
    :at_middleware
    |> Application.get_env(key1, %{})
    |> Keyword.put(key2, env_val)
    |> set_config(key1)
  end

  defp set_config(env_val, config_key) do
    Application.put_env(:at_middleware, config_key, env_val)
  end

  defp set_config(env_val, config_key, app) do
    Application.put_env(app, config_key, env_val)
  end
end
