defmodule Dockup.Container do
  defstruct [name: nil, deployment_id: nil, image: nil, tag: nil, env_vars: [], command: [], args: [], init_containers: [], ports: []]
end
