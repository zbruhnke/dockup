ExUnit.configure(exclude: [:skip, :integration])
ExUnit.start()
Dockup.Config.set_configs_from_env()
