defmodule DockupUi.CallbackTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory

  alias DockupUi.{
    Callback
  }

  test "lambda returns a function" do
    deployment = insert(:deployment)
    assert is_function(Callback.lambda(%{deployment: deployment}, nil))
  end

  test "callback runs DeploymentStatusUpdateService" do
    defmodule FakeStatusUpdateService do
      def run(_status, %{id: 1}, "fake_payload") do
        send self(), :status_updated
      end
    end

    deployment = insert(:deployment, id: 1)

    lambda = Callback.lambda(%{deployment: deployment}, FakeStatusUpdateService)
    lambda.(:queued, "fake_payload")
    assert_received :status_updated
  end
end
