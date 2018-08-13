defmodule Dockup.Spec do
  @moduledoc """
  Behaviour to be implemented by backends
  """

  alias Dockup.Container

  @doc """
  This function is used to start a container
  It takes a %Container{} struct as the argument, uses the backend
  to start a container and gives back a container handle as a string.
  The container handle can be used to uniquely reference the container
  in the backend.
  """
  @callback start(%Container{}) :: {:ok, String.t()}

  @doc """
  This function is used to hibernate a container. Used to save money :D
  It takes a container handle as the argument.
  """
  @callback hibernate(String.t()) :: :ok

  @doc """
  This function is used to wake up a hibernated container.
  It takes a container handle as the argument.
  """
  @callback wake_up(String.t()) :: :ok

  @doc """
  This function is used to delete a container.
  It takes a container handle as the argument.
  """
  @callback delete(String.t()) :: :ok

  @doc """
  This function is used to get the status of a container.
  It takes a container handle as the argument.
  Backends should return one of these states:
  1. :pending - When the backend is pulling the image and preparing to run
  2. :running - When the container is running (or starting or restarting)
  3. :succeeded - When the container terminated after running successfully
  4. :failed - When the container terminated in failure
  5. :unknown - When the status of the container cannot be fetched

  # Dockup Deployment status and pod status
  # (By deployment below, we mean the deployment entity in DockupUI)
  # A deployment always starts in "queued" status.
  # Atleast one pod -> "pending", deployment -> "starting"
  # All pods-> "running" and public URLs accessible, deployment -> "started"
  # Backend started hibernating, deployment -> "hibernating"
  # All pods -> "unknown", deployment -> "hibernated"
  # Backend started waking up, deployment -> "waking_up"
  # All pods -> "running", deployment -> "started"
  # Backend started deleting, deployment -> "deleting"
  # All pods -> "unknown", deployment -> "deleted"
  # Any pod -> "Failed", deployment -> "failed"
  """
  @callback status(String.t()) :: :pending | :running | :succeeded | :failed | :unknown

  @doc """
  This function is used to get the logs of a container.
  """
  @callback logs(String.t()) :: String.t()

  @doc """
  This function is used to get the hostname for a container.
  It takes a container struct as the argument.
  """
  @callback hostname(integer(), String.t()) :: String.t()
end
