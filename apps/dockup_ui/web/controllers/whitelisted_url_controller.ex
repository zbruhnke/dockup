defmodule DockupUi.WhitelistedUrlController do
  use DockupUi.Web, :controller

  alias DockupUi.WhitelistedUrl

  def new(conn, _params) do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"whitelisted_url" => whitelisted_url_params}) do
    changeset = WhitelistedUrl.changeset(%WhitelistedUrl{}, whitelisted_url_params)

    case Repo.insert(changeset) do
      {:ok, _whitelisted_url} ->
        conn
        |> put_flash(:info, "Whitelisted url created successfully.")
        |> redirect(to: whitelisted_url_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    whitelisted_url = Repo.get!(WhitelistedUrl, id)
    changeset = WhitelistedUrl.changeset(whitelisted_url)
    render(conn, "edit.html", whitelisted_url: whitelisted_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "whitelisted_url" => whitelisted_url_params}) do
    whitelisted_url = Repo.get!(WhitelistedUrl, id)
    changeset = WhitelistedUrl.changeset(whitelisted_url, whitelisted_url_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Whitelisted url updated successfully.")
        |> redirect(to: config_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", whitelisted_url: whitelisted_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    whitelisted_url = Repo.get!(WhitelistedUrl, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(whitelisted_url)

    conn
    |> put_flash(:info, "Whitelisted url deleted successfully.")
    |> redirect(to: config_path(conn, :index))
  end
end
