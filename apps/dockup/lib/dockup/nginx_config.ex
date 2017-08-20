defmodule Dockup.NginxConfig do
  require Logger

  @subdomain_character_range ?a..?z

  def dockup_config(dockup_domain, dockup_ip, logio_ip, use_ssl \\ false) do
    get_dockup_config(dockup_domain, dockup_ip, logio_ip, use_ssl)
  end

  def nginx_conf do
    """
    user  nginx;
    worker_processes  1;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;

    events {
      worker_connections  1024;
    }

    http {
      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;

      log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

      access_log  /var/log/nginx/access.log  main;
      sendfile        on;
      keepalive_timeout  65;

      server {
        return 404;
      }
      include /etc/nginx/dockup.conf;
      include /etc/nginx/conf.d/*.conf;
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

  def delete_config(project_id) do
    Logger.info "Deleting deployment-#{project_id} nginx config file"
    File.rm!(config_file(project_id))
  end

  @doc """
  Returns a URL with a random subdomain. The subdomain string starts with "d"
  and ends with "p", a naive workaround to ensure it starts and ends with
  alphanumerics.
  """
  def create_url(len \\ 10) do
    random_string =
      @subdomain_character_range
      |> Enum.take_random(len)
      |> to_string
    "#{random_string}.#{Dockup.Configs.domain}"
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
          acc ++ [%{"port" => container_port, "url" => "http://#{url}"}]
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

  defp get_dockup_config(dockup_domain, dockup_ip, logio_ip, true) do
    """
    server {
      listen 80;
      server_name #{dockup_domain};
      return 301 https://#{dockup_domain}$request_uri;
    }

    server {
      listen 443 ssl;
      server_name #{dockup_domain} ;
      ssl_certificate /etc/nginx/dockup_ssl/crt;
      ssl_certificate_key /etc/nginx/dockup_ssl/key;

      #{default_proxy_passes(dockup_ip, logio_ip)}
    }
    """
  end

  defp get_dockup_config(dockup_domain, dockup_ip, logio_ip, false) do
    """
    server {
      listen 80;

      server_name #{dockup_domain} ;

      #{default_proxy_passes(dockup_ip, logio_ip)}
    }
    """
  end

  defp default_proxy_passes(dockup_ip, logio_ip) do
    """
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
    """
  end
end
