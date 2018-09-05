defmodule DockupUi.Metrics do
  def send(container_count) do
    has_customer_name = not is_nil(get_customer_name())
    has_endpoint = not is_nil(get_endpoint())

    if(has_customer_name and has_endpoint) do
      route = "/containers/" <> get_customer_name() <> ".json"
      url = get_endpoint() <> route
      body = Poison.encode!(%{count: container_count, timeStamp: DateTime.utc_now()})

      spawn(fn ->
        HTTPotion.post(
          url,
          body: body,
          headers: ["Content-Type": "application/json"]
        )
      end)
    end
  end

  def get_customer_name do
    Application.get_env(:dockup_ui, :customer_name)
  end

  def get_endpoint do
    Application.get_env(:dockup_ui, :metrics_endpoint)
  end
end
