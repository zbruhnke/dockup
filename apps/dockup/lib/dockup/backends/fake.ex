defmodule Dockup.Backends.Fake do
  alias Dockup.Spec

  @behaviour Spec

  @impl Spec
  def start(_) do
    "fake_container_handle"
  end

  @impl Spec
  def hibernate(_) do
    :ok
  end

  @impl Spec
  def wake_up(_) do
    :ok
  end

  @impl Spec
  def delete(_) do
    :ok
  end

  @impl Spec
  def status(_) do
    :running
  end

  @impl Spec
  def logs(_) do
    "Log string"
  end
end
