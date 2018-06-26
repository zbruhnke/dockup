defmodule Dockup.DefaultCallback do
  require Logger

  def update_status(event, deployment_id) do
    Logger.info "#{event} event was triggered for deployment: #{deployment_id}"
  end

  def set_urls(deployment_id, urls) do
    Logger.info "URLs : #{inspect urls} to be set for deployment : #{deployment_id}"
  end

  def set_log_url(deployment_id, log_url) do
    Logger.info "Log URL : #{log_url} to be set for deployment : #{deployment_id}"
  end
end
