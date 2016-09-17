defmodule Dockup.NginxConfig do
  require Logger

  def default_config(dockup_ip, logio_ip) do
    """
    server {
      listen 80 default_server;
      listen [::]:80 default_server ipv6only=on;
      listen 443 default_server ssl;
      listen [::]:443 default_server ssl ipv6only=on;

      server_name _ ;

      location / {
        proxy_pass http://#{dockup_ip}:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      }

      location /deployment_logs/ {
        proxy_pass http://#{logio_ip}:28778/;
      }

      location /socket.io {
        proxy_pass http://#{logio_ip}:28778;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      }
    }
    """
  end

  # accepts a list of tuples of the format:
  # [{"container_ip", "host_port", "service_url"},...]
  def config_proxy_passing_port(proxy_urls) do
    proxy_urls
    |> Enum.map(&proxy_passing_port&1)
    |> Enum.join("\n")
  end

  def config_file(project_id) do
    Path.join(Dockup.Configs.nginx_config_dir, "#{project_id}.conf")
  end

  # Given a project_id and docker port mappings, writes the nginx config to
  # proxy pass service URLs to the docker ports
  # port_mappings should be of the format :
  # %{"<service name>" => {"container_ip", [{"<container_port>", <"host_port">}, ...]}, ...}
  def write_config(project_id, port_mappings, url_creator \\ __MODULE__) do
    Logger.info "Writing nginx config to serve #{project_id}"

    service_port_urls = generate_service_port_urls(port_mappings, url_creator)
    proxy_urls = format_proxy_urls(service_port_urls)
    config = config_proxy_passing_port(proxy_urls)
    File.write(config_file(project_id), config)
    format_service_urls(service_port_urls)
  end

  @doc """
  Returns a URL with a random subdomain. The subdomain string starts with "d"
  and ends with "p", a naive workaround to ensure it starts and ends with
  alphanumerics.

      iex> url = Dockup.NginxConfig.create_url
      ...> domain = Dockup.Configs.domain
      ...> url =~ ~r/d\\w{10}p.#\{domain}/
      true
  """
  def create_url(len \\ 10) do
    random_string =
      len
      |> :crypto.strong_rand_bytes
      |> Base.url_encode64
      |> binary_part(0, len)
    "d#{random_string}p.#{Dockup.Configs.domain}"
  end

  defp generate_service_port_urls(port_mappings, url_creator) do
    Enum.reduce(port_mappings, %{}, fn {service, {ip, ports}}, acc ->
      value = Enum.reduce(ports, [], fn {container_port, host_port}, acc_1 ->
        acc_1 ++ [{container_port, host_port, url_creator.create_url}]
      end)
      Map.merge acc, %{service => {ip, value}}
    end)
  end

  # service_port_urls is of the format:
  # %{"service_name" => {"container_ip", [{"container_port", "host_port", "service_url"},...]}, ...}
  # returns:
  # %{"<service name>" => [%{"port" => "<container_port>", "url" => <"url">}, ...], ...}
  defp format_service_urls(service_port_urls) do
    Enum.reduce(service_port_urls, %{}, fn {service, {_ip, port_details}}, map_acc ->
      if Enum.empty? port_details do
        map_acc
      else
        value = Enum.reduce(port_details, [], fn {container_port, _, url}, acc ->
          acc ++ [%{"port" => container_port, "url" => url}]
        end)
        Map.merge map_acc, %{service => value}
      end
    end)
  end

  # service_port_urls is of the format:
  # %{"service_name" => {"container_ip", [{"container_port", "host_port", "service_url"},...]}, ...}
  # returns:
  # [{"container_ip", "host_port", "service_url"}, ...]
  defp format_proxy_urls(service_port_urls) do
    Enum.reduce(service_port_urls, [], fn {_service, {ip, port_details}}, acc ->
      acc ++ Enum.reduce(port_details, [], fn {container_port, _host_port, url}, acc_1 ->
        acc_1 ++ [{ip, container_port, url}]
      end)
    end)
  end

  defp proxy_passing_port({ip, port, url}) do
    """
    server {
      listen 80;
      server_name #{url};

      location / {
        proxy_pass http://#{ip}:#{port};
        proxy_set_header Host $host;
      }
    }
    """
  end
end
