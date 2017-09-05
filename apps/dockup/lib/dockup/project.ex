defmodule Dockup.Project do
  require Logger
  import Dockup.Retry

  @subdomain_character_range ?a..?z

  def clone_repository(project_id, repository, branch, command \\ Dockup.Command) do
    project_dir = project_dir(project_id)
    Logger.info "Cloning #{repository} : #{branch} into #{project_dir}"
    File.rm_rf(project_dir)
    File.mkdir_p!(project_dir)
    case command.run("git", ["clone", "--branch=#{branch}", "--depth=1", repository, project_dir]) do
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
  def wait_till_up(urls, http \\ __MODULE__, interval \\ 5000)

  def wait_till_up([], _, _) do
    raise DockupException, "No URLs to wait for."
  end

  def wait_till_up(urls, http, interval) do
    for url <- urls do
      response = 200
      # Retry 30 times in an interval of 5 seconds
      retry 30 in interval do
        Logger.info "Checking if #{url} returns http satus #{response}"
        ^response = http.get_status(url)
      end
      Logger.info "URL #{url} seem up because they respond with #{response}."
    end
  end

  #def start(project_id, container \\ Dockup.Container, nginx_config \\ Dockup.NginxConfig) do
    #container.start_containers(project_id)
    #port_mappings = container.port_mappings(project_id)
    #port_urls = nginx_config.write_config(project_id, port_mappings)
    #container.reload_nginx
    #port_urls
  #end

  #def stop(project_id, container \\ Dockup.Container, nginx_config \\ Dockup.NginxConfig) do
    #container.stop_containers(project_id)
    #nginx_config.delete_config(project_id)
    #container.reload_nginx
  #end

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
end
