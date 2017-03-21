defmodule TheBestory.Web.TopicController do
  use TheBestory.Web, :controller

  alias TheBestory.Schema
  alias TheBestory.Schema.Topic

  action_fallback TheBestory.Web.FallbackController

  def index(conn, _params) do
    topics = Schema.list_topics()
    render(conn, "index.json", topics: topics)
  end

  def create(conn, %{"topic" => topic_params}) do
    with {:ok, %Topic{} = topic} <- Schema.create_topic(topic_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", topic_path(conn, :show, topic))
      |> render("show.json", topic: topic)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Schema.get_topic!(id)
    render(conn, "show.json", topic: topic)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Schema.get_topic!(id)

    with {:ok, %Topic{} = topic} <- Schema.update_topic(topic, topic_params) do
      render(conn, "show.json", topic: topic)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Schema.get_topic!(id)
    with {:ok, %Topic{}} <- Schema.delete_topic(topic) do
      send_resp(conn, :no_content, "")
    end
  end
end
