defmodule DockupUi.Callback.Null do
  alias DockupUi.{
    CallbackProtocol,
    CallbackProtocol.Defaults
  }

  defstruct []

  defimpl CallbackProtocol, for: __MODULE__ do
    use Defaults

    def common_callback(_data, _deployment, _payload) do
      :ok
    end
  end
end
