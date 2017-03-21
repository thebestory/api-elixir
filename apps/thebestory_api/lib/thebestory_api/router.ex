defmodule TheBestory.API.Router do
  use TheBestory.API, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TheBestory.API do
    pipe_through :api

    resources "/topics", TopicController, except: [:new, :edit]
    resources "/posts", PostController, except: [:new, :edit]
  end
end
