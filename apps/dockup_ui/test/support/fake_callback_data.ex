
defmodule FakeCallbackData do
  alias DockupUi.{
    CallbackProtocol
  }

  defstruct noop: false

  defimpl CallbackProtocol, for: FakeCallbackData do
    use CallbackProtocol.Defaults

    def started(%{noop: noop}, deployment, payload) do
      unless noop do
        {pid, payload} = payload
        send pid, {:started, deployment, payload}
      end
    end

    def common_callback(%{noop: noop}, deployment, payload) do
      unless noop do
        {pid, payload} = payload
        send pid, {:common_callback, deployment, payload}
      end
    end
  end
end

