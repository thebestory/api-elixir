defmodule TheBestory.API.TopicController do
  use TheBestory.API, :controller

  alias TheBestory.Schema.Topic

  action_fallback TheBestory.API.FallbackController

  def index(conn, _params) do
    topics = Topic.list()
    render(conn, "index.json", topics: topics)
  end

  def create(conn, %{"topic" => params}) do
    with {:ok, %Topic{} = topic} <- Topic.create(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", topic_path(conn, :show, topic))
      |> render("show.json", topic: topic)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Topic.get!(id)
    render(conn, "show.json", topic: topic)
  end

  def update(conn, %{"id" => id, "topic" => params}) do
    topic = Topic.get!(id)

    with {:ok, %Topic{} = topic} <- Topic.update(topic, params) do
      render(conn, "show.json", topic: topic)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Topic.get!(id)
    with {:ok, %Topic{}} <- Topic.delete(topic) do
      send_resp(conn, :no_content, "")
    end
  end
end
