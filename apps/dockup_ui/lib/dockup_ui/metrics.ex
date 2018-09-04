defmodule DockupUi.Metrics do
  def send(container_count, metrics_url) do
    has_customer_name = not is_nil(get_customer_name())

    if(has_customer_name) do
      route = "/containers/" <> get_customer_name() <> ".json"
      url = metrics_url <> route
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
end
