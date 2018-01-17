defmodule Dockup.Project do
  require Logger
  import Dockup.Retry

  @subdomain_character_range ?a..?z

  def clone_repository(project_id, repository, branch, command \\ Dockup.Command) do
    workdir = Application.fetch_env!(:dockup, :workdir)
    project_dir = project_dir(project_id)
    Logger.info "Cloning #{repository} : #{branch} into #{project_dir}"
    File.rm_rf(project_dir)
    File.mkdir_p!(project_dir)
    case command.run("git", ["clone", "--branch=#{branch}", "--depth=1", repository, project_dir], workdir) do
      {_out, 0} -> :ok
      {out, _} -> raise out
    end
  rescue
    error ->
      raise DockupException, "Cannot clone #{branch} of #{repository}. Error: #{error.message}"
  end

  def delete_repository(project_id) do
    project_dir = project_dir(project_id)
    Logger.info "Deleteing project repository at #{project_dir}"
    File.rm_rf(project_dir)
  end

  def project_dir(project_id) do
    workdir = Application.fetch_env!(:dockup, :workdir)
    Path.join([workdir, "clones", project_id])
  end

  # Waits until the urls all return expected HTTP status.
  # Currently, assuming that URLs are for static sites
  # and they return 200.
  def wait_till_up(urls, project_id, http \\ __MODULE__, interval \\ 5000)

  def wait_till_up([], _, _, _) do
    raise DockupException, "No URLs to wait for."
  end

  def wait_till_up(urls, project_id, http, interval) do
    for url <- urls do
      url = url <> root_path(project_id)
      response = http_status(project_id)

      # Retry 60 times in an interval of 5 seconds
      retry 60 in interval do
        Logger.info "Checking if #{url} returns http satus #{response}"
        ^response = http.get_status(url)
      end
      Logger.info "URL #{url} seem up because they respond with #{response}."
    end
  end

  def create_url(len \\ 10) do
    domain = Application.fetch_env!(:dockup, :domain)
    random_string =
      @subdomain_character_range
      |> Enum.take_random(len)
      |> to_string
    "#{random_string}.#{domain}"
  end

  def get_status(url) do
    HTTPotion.get(url).status_code
  end

  def root_path(project_id) do
    config(project_id)["root_path"] || ""
  end

  def http_status(project_id) do
    config(project_id)["expected_http_status"] || 200
  end

  def config(project_id) do
    config_file = config_file(project_id)
    case File.read(config_file) do
      {:ok, binary} ->
        try_json_parse(binary)
      {:error, _} ->
        %{}
    end
  end

  def config_file(project_id) do
    workdir = project_dir(project_id)
    Path.join(workdir, ".dockup.json")
  end

  defp try_json_parse(binary) do
    case Poison.decode(binary) do
      {:ok, map} when is_map(map) -> map
      _ -> %{}
    end
  end
end
