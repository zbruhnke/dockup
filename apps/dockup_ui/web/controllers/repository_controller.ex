defmodule DockupUi.RepositoryController do
  use DockupUi.Web, :controller

  alias DockupUi.Repository
  plug DockupUi.Plugs.AuthorizeUser

  def new(conn, _) do
    changeset = Repository.changeset(%Repository{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"repository" => repository_params}) do
    repository_params = Map.put(repository_params, "organization_id", conn.params["organization_id"])
    changeset = Repository.changeset(%Repository{}, repository_params)

    case Repo.insert(changeset) do
      {:ok, _repository} ->
        conn
        |> put_flash(:info, "Repository created successfully.")
        |> redirect(to: organization_repository_path(conn, :new, conn.params["organization_id"]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    repository = Repo.get_by!(Repository, id: id, organization_id: conn.params["organization_id"])
    changeset = Repository.changeset(repository)
    render(conn, "edit.html", repository: repository, changeset: changeset)
  end

  def update(conn, %{"id" => id, "repository" => repository_params}) do
    repository = Repo.get_by!(Repository, id: id, organization_id: conn.params["organization_id"])
    repository_params = Map.put(repository_params, "organization_id", conn.params["organization_id"])
    changeset = Repository.changeset(repository, repository_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Repository updated successfully.")
        |> redirect(to: organization_config_path(conn, :index, conn.params["organization_id"]))
      {:error, changeset} ->
        render(conn, "edit.html", repository: repository, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    repository = Repo.get_by!(Repository, id: id, organization_id: conn.params["organization_id"])
    Repo.delete!(repository)

    conn
    |> put_flash(:info, "Repository deleted successfully.")
    |> redirect(to: organization_config_path(conn, :index, conn.params["organization_id"]))
  end
end
