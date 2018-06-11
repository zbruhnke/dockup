defmodule DockupSpec do
  @moduledoc """
  Protocol to be implemented by Dockup backends
  """

  @doc """
  Called when the Dockup app starts up. Use this place to initialize runtime
  configurations and setup the environment as required.
  """
  @callback initialize() :: any

  @doc """
  This function is used to queue deployments.
  First argument is a struct with the keys [:id, :git_url, :branch]
  Second argument is a callback function which takes an atom as the first argument and a payload as the second argument
  """
  @callback deploy(%{id: number(), git_url: String.t(), branch: String.t()}, (:atom, any() -> any())) :: any()

  @doc """
  This function is used to delete deployments.
  First argument is a project identifier which is a number.
  Second argument is a callback function which takes an atom as the first argument and a payload as the second argument
  """
  @callback destroy(number(), (:atom, any() -> any())) :: any()

  @doc """
  This function is used to hibernate deployments. Used to save money :D
  First argument is a project identifier which is a number.
  Second argument is a callback function which takes an atom as the first argument and a payload as the second argument
  """
  @callback hibernate(number(), (:atom, any() -> any())) :: any()
end
