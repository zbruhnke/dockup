defmodule DockupUi.Router do
  use DockupUi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :with_current_user do
    plug DockupUi.Plugs.GetCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DockupUi do
    pipe_through :browser
    get "/", DeploymentController, :home
  end

  scope "/", DockupUi do
    pipe_through [:browser, :with_current_user]

    get "/deploy", DeploymentController, :new
    resources "/deployments", DeploymentController, only: [:new, :index, :show]

    resources "/organizations", OrganizationController, only: [] do
      resources "/config", ConfigController, only: [:index]
      resources "/repositories", RepositoryController, except: [:index, :show]
    end
  end

  scope "/api", as: :api, alias: DockupUi.API do
    pipe_through :api

    resources "/deployments", DeploymentController, only: [:create, :index, :show, :delete]
    resources "/github_webhook", GithubWebhookController, only: [:create]
  end

  scope "/auth", DockupUi do
    pipe_through :browser

    get "/", AuthController, :new
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
end
