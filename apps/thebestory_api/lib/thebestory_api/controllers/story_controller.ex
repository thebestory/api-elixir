defmodule TheBestory.API.StoryController do
  use TheBestory.API, :controller

  alias TheBestory.Schema
  alias TheBestory.Store

  action_fallback TheBestory.API.FallbackController

  def index(conn, _params) do
    stories = Story.list()
    render(conn, "index.json", storys: storys)
  end

  def create(conn, %{"story" => params}) do
    with {:ok, %Story{} = story} <- Story.create(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", story_path(conn, :show, story))
      |> render("show.json", story: story)
    end
  end

  def show(conn, %{"id" => id}) do
    story = Story.get!(id, :preload)
    render(conn, "show.json", story: story)
  end

  def update(conn, %{"id" => id, "story" => params}) do
    story = Story.get!(id)

    with {:ok, %Story{} = story} <- Story.update(story, params) do
      render(conn, "show.json", story: story)
    end
  end

  def delete(conn, %{"id" => id}) do
    story = Story.get!(id)

    with {:ok, %Story{}} <- Story.delete(story) do
      send_resp(conn, :no_content, "")
    end
  end
end
