defmodule DockupUi.Router do
  use DockupUi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DockupUi do
    pipe_through :browser

    get "/", DeploymentController, :new
    resources "/deployments", DeploymentController, only: [:new, :index, :show]
    resources "/config", ConfigController, only: [:index]
    resources "/subdomains", SubdomainController, except: [:index, :show]
  end

  scope "/api", as: :api, alias: DockupUi.API do
    pipe_through :api

    resources "/deployments", DeploymentController, only: [:create, :index, :show, :delete] do
      put "/hibernate", DeploymentController, :hibernate
      put "/wake_up", DeploymentController, :wake_up
    end

    resources "/gcp_webhook", GcpPubSubController, only: [:create]
  end
end
