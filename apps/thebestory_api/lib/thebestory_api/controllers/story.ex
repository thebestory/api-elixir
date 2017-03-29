defmodule TheBestory.API.Controller.Story do
  use TheBestory.API, :controller

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Store

  @fallback_controller Controller.Fallback

  plug :put_view, View.Story
  action_fallback @fallback_controller

  plug Guardian.Plug.EnsureAuthenticated, [handler: @fallback_controller] 
       when action in [:create, :update, :delete]
  plug Guardian.Plug.EnsureResource, [handler: @fallback_controller]
       when action in [:create, :update, :delete]

  @preload_fields [:author, :topic]

  def index(conn, _params) do
    stories = Store.Story.list() |> Repo.preload(@preload_fields)
    render(conn, "index.json", stories: stories)
  end

  def create(conn, %{"story" => params}) do
    with {:ok, %Story{} = story} <- Store.Story.create(params) do
      story = story |> Repo.preload(@preload_fields)

      conn
      |> put_status(:created)
      |> put_resp_header("location", story_path(conn, :show, story))
      |> render("show.json", story: story)
    end
  end

  def show(conn, %{"id" => id}) do
    story = Store.Story.get!(id) |> Repo.preload(@preload_fields)
    render(conn, "show.json", story: story)
  end

  def update(conn, %{"id" => id, "story" => params}) do
    story = Store.Story.get!(id)

    with {:ok, %Story{} = story} <- Store.Story.update(story, params) do
      render(conn, "show.json", story: story)
    end
  end

  def delete(conn, %{"id" => id}) do
    story = Store.Story.get!(id)

    with {:ok, %Story{}} <- Store.Story.delete(story) do
      send_resp(conn, :no_content, "")
    end
  end
end
