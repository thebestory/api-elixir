defmodule TheBestory.API.Router do
  use TheBestory.API, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", TheBestory.API do
    pipe_through :api

    scope "/users" do
      get    "/",    Controller.User, :index,  as: :user
      post   "/",    Controller.User, :create, as: :user

      get    "/:id", Controller.User, :show,   as: :user
      patch  "/:id", Controller.User, :update, as: :user
      put    "/:id", Controller.User, :update
      delete "/:id", Controller.User, :delete, as: :user
    end

    scope "/session" do
      get    "/", Controller.Session, :show,   as: :session
      post   "/", Controller.Session, :create, as: :session
      patch  "/", Controller.Session, :update, as: :session
      put    "/", Controller.Session, :update, as: :session
      delete "/", Controller.Session, :delete, as: :session
    end

    scope "/topics" do
      get    "/",    Controller.Topic, :index,  as: :topic
      post   "/",    Controller.Topic, :create, as: :topic

      get    "/:id", Controller.Topic, :show,   as: :topic
      patch  "/:id", Controller.Topic, :update, as: :topic
      put    "/:id", Controller.Topic, :update
      delete "/:id", Controller.Topic, :delete, as: :topic
    end

    scope "/stories" do
      get    "/latest", Controller.Story, :latest, as: :story_latest
      get    "/hot",    Controller.Story, :hot,    as: :story_hot
      get    "/top",    Controller.Story, :top,    as: :story_top
      get    "/random", Controller.Story, :random, as: :story_random

      post   "/",    Controller.Story, :create, as: :story

      get    "/:id", Controller.Story, :show,   as: :story
      patch  "/:id", Controller.Story, :update, as: :story
      put    "/:id", Controller.Story, :update
      delete "/:id", Controller.Story, :delete, as: :story
    end
  end
end
