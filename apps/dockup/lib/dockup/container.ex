defmodule Dockup.Container do
  defstruct [id: nil, name: nil, deployment_id: nil, image: nil, tag: nil, env_vars: [], command: [], args: [], init_containers: [], ports: []]
end

# Example:
#
# %Container{
#   name: "my-frontend",
#   deployment_id: 1,
#   image: "gcr.io/my-frontend-image",
#   tag: "master",
#   env_vars: [{"FOO", "BAR"}],
#   command: ["node"],
#   args: ["./run", "--production"],
#   init_containers: %{
#     image: "gcr.io/wait-for-postgres",
#     tag: "latest",
#     command: ["./start"],
#     args: ["--port", "5678"],
#     env_vars: [{"FOO", "BAR"}]
#   },
#   ports: [
#     %{port: 80, public: true, host: "staging.dockup.company.com"}
#   ]
# }
