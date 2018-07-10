defmodule DockupUi.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  def find_or_create(%Auth{} = auth) do
    allowed_domains =
      Application.get_env(:dockup_ui, :google_client_domains, "")
      |> String.split(",")

    if Enum.member?(allowed_domains, auth.info.urls[:website]) do
      {:ok, basic_info(auth)}
    else
      {:error, "Not authorized!"}
    end
  end

  defp basic_info(auth) do
    IO.inspect auth
    auth.extra.raw_info.user["name"] || auth.extra.raw_info.user["email"]
  end
end
