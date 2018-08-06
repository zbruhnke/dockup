defmodule DockupUi.SubdomainController do
  use DockupUi.Web, :controller

  alias DockupUi.Subdomain

  def new(conn, _params) do
    changeset = Subdomain.changeset(%Subdomain{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"subdomain" => subdomain_params}) do
    changeset = Subdomain.changeset(%Subdomain{}, subdomain_params)

    case Repo.insert(changeset) do
      {:ok, _subdomain} ->
        conn
        |> put_flash(:info, "Subdomain created successfully.")
        |> redirect(to: subdomain_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    subdomain = Repo.get!(Subdomain, id)
    changeset = Subdomain.changeset(subdomain, %{})
    render(conn, "edit.html", subdomain: subdomain, changeset: changeset)
  end

  def update(conn, %{"id" => id, "subdomain" => subdomain_params}) do
    subdomain = Repo.get!(Subdomain, id)
    changeset = Subdomain.changeset(subdomain, subdomain_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Subdomain updated successfully.")
        |> redirect(to: config_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", subdomain: subdomain, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    subdomain = Repo.get!(Subdomain, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(subdomain)

    conn
    |> put_flash(:info, "Subdomain deleted successfully.")
    |> redirect(to: config_path(conn, :index))
  end
end
