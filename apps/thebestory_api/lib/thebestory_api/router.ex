defmodule TheBestory.API.Router do
  use TheBestory.API, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", TheBestory.API do
    pipe_through :api

    resources "/topics", TopicController, except: [:new, :edit]
    resources "/posts", PostController, except: [:new, :edit]
  end
end
