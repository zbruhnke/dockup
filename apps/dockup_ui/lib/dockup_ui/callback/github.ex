defmodule DockupUi.Callback.Github do
  alias DockupUi.{
    CallbackProtocol,
    CallbackProtocol.Defaults
  }

  defstruct [:owner, :repo, :url]

  defimpl CallbackProtocol, for: __MODULE__ do
    use Defaults
  end
end
