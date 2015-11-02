defmodule Rumbl.Router do
  use Rumbl.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # With our plug in place, we can begin to use this information downstream
    plug Rumbl.Auth, repo: Rumbl.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Rumbl do
    pipe_through :browser # Use the default browser stack

    get       "/",              PageController, :index
    resources "/users",         UserController
    # GET new_session to show a new session
    # POST session to login
    # DELETE session/:id to logout
    resources "/sessions",      SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Rumbl do
  #   pipe_through :api
  # end
end
