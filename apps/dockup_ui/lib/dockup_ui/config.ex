defmodule DockupUi.Config do
  require Logger

  def set_configs_from_env do
    for {env_var, config_key, type} <- configs() do
      set_config(System.get_env(env_var), config_key, type)
    end
  end

  defp configs do
    [
      {"DOCKUP_BACKEND", :backend_module, :module}
    ]
  end

  defp set_config(nil, _, _) do
    # Do nothing if env var is not set
  end

  defp set_config(env_val, config_key, :module) do
    module = module_for_backend(env_val)
    Application.put_env(:dockup_ui, config_key, module)
  end

  defp module_for_backend(env_val) do
    case env_val do
      "compose" -> Dockup.Backends.Compose
      "helm" -> Dockup.Backends.Helm
      "fake" -> FakeDockup
      _ -> raise "unknown backend #{env_val}"
    end
  end
end
