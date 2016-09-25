defmodule DockupUi.Callback.Web do
  require Logger

  alias DockupUi.{
    CallbackProtocol,
    CallbackProtocol.Defaults
  }

  defstruct [:callback_url]

  defimpl CallbackProtocol, for: __MODULE__ do
    use Defaults

    def common_callback(data, deployment, payload) do
      callback_url = data.callback_url
      if is_nil(callback_url) do
        :ok
      else
        Logger.info "Sending POST request to #{callback_url} for event #{deployment.status} of deployment: #{deployment.id}"

        request_body = Poison.encode! %{
          status: deployment.status,
          git_url: deployment.git_url,
          branch: deployment.branch,
          payload: payload
        }

        response = HTTPotion.post callback_url, [
          body: request_body,
          headers: ["Content-Type": "application/json"]
        ]

        Logger.info "POST request to #{callback_url} responded with status #{response.status_code}"
      end
    end
  end
end
