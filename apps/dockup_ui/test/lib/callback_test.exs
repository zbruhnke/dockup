defmodule DockupUi.CallbackTest do
  use DockupUi.ModelCase, async: true
  import DockupUi.Factory
  import ExUnit.CaptureLog

  alias DockupUi.{
    Callback,
    CallbackProtocol
  }

  {:ok, binary} = Protocol.consolidate(CallbackProtocol, [FakeCallbackData])
  :code.load_binary(CallbackProtocol, 'callback_test.exs', binary)

  test "lambda returns a function" do
    deployment = insert(:deployment)
    assert is_function(Callback.lambda(deployment, nil))
  end

  test "callback runs DeploymentStatusUpdateService" do
    defmodule FakeStatusUpdateService do
      def run(_status, 1, "fake_payload") do
        send self(), :status_updated
      end
    end

    deployment = insert(:deployment, id: 1)

    lambda = Callback.lambda(deployment, %FakeCallbackData{noop: true}, FakeStatusUpdateService)
    lambda.(:queued, "fake_payload")
    assert_received :status_updated
  end

  test "callback triggers callback implementation based on callback data" do
    defmodule NoopStatusUpdateService do
      def run(_status, _id, _payload), do: :ok
    end

    deployment = insert(:deployment, id: 1)

    lambda = Callback.lambda(deployment, %FakeCallbackData{}, NoopStatusUpdateService)

    # When event is not implemented, falls back to common_callback
    lambda.(:queued, {self(), "fake_payload"})
    assert_receive {:common_callback, ^deployment, "fake_payload"}

    # When event is implemented, uses the overridden implementation
    lambda.(:started, {self(), "fake_payload"})
    assert_receive {:started, ^deployment, "fake_payload"}

    # When event is invalid
    logs = capture_log(fn ->
      lambda.(:not_a_real_event, {self(), "fake_payload"})
      refute_receive {:not_a_real_event, ^deployment, "fake_payload"}
    end)
    assert logs =~ "Unknown callback event triggered: :not_a_real_event"
  end
end
