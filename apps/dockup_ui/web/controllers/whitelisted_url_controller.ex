defmodule DockupUi.WhitelistedUrlController do
  use DockupUi.Web, :controller

  alias DockupUi.WhitelistedUrl
  plug DockupUi.Plugs.AuthorizeUser

  def new(conn, _) do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"whitelisted_url" => whitelisted_url_params}) do
    whitelisted_url_params = Map.put(whitelisted_url_params, "organization_id", conn.params["organization_id"])
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, whitelisted_url_params)

    case Repo.insert(changeset) do
      {:ok, _whitelisted_url} ->
        conn
        |> put_flash(:info, "Whitelisted url created successfully.")
        |> redirect(to: organization_whitelisted_url_path(conn, :new, conn.params["organization_id"]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    whitelisted_url = Repo.get_by!(WhitelistedUrl, id: id, organization_id: conn.params["organization_id"])
    changeset = WhitelistedUrl.changeset(whitelisted_url)
    render(conn, "edit.html", whitelisted_url: whitelisted_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "whitelisted_url" => whitelisted_url_params}) do
    whitelisted_url = Repo.get_by!(WhitelistedUrl, id: id, organization_id: conn.params["organization_id"])
    whitelisted_url_params = Map.put(whitelisted_url_params, "organization_id", conn.params["organization_id"])
    changeset = WhitelistedUrl.changeset(whitelisted_url, whitelisted_url_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Whitelisted url updated successfully.")
        |> redirect(to: organization_config_path(conn, :index, conn.params["organization_id"]))
      {:error, changeset} ->
        render(conn, "edit.html", whitelisted_url: whitelisted_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    whitelisted_url = Repo.get_by!(WhitelistedUrl, id: id, organization_id: conn.params["organization_id"])
    Repo.delete!(whitelisted_url)

    conn
    |> put_flash(:info, "Whitelisted url deleted successfully.")
    |> redirect(to: organization_config_path(conn, :index, conn.params["organization_id"]))
  end
end
