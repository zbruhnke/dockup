defmodule DockupUi.Metrics do
    def send(containers_length) do
      route = "/" <> get_customer_name() <> ".json"
      url = get_firebase_url() <>  route
      body = Poison.encode!(%{count: containers_length , timeStamp: DateTime.utc_now })
      spawn fn ->
        HTTPotion.post url, [
          body: body,
          headers: ["Content-Type": "application/json"]
        ]
    end
    end

    def get_customer_name do
        Application.get_env(:dockup_ui, :customer_name) || "INTERNAL"
    end

    def get_firebase_url do
        Application.get_env(:dockup_ui, :metrics_endpoint) || raise "expected DOCKUP_METRICS_ENDPOINT env var to be set"
    end
end
