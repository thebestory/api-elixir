defmodule TheBestory.API.Controller.Topic do
  use TheBestory.API, :controller

  alias TheBestory.Schema.Topic
  alias TheBestory.Stores

  @fallback_controller Controller.Fallback

  plug :put_view, View.Topic
  action_fallback @fallback_controller

  plug Guardian.Plug.EnsureAuthenticated, [handler: @fallback_controller] 
       when action in [:create, :update, :delete]
  plug Guardian.Plug.EnsureResource, [handler: @fallback_controller]
       when action in [:create, :update, :delete]

  def index(conn, _params) do
    topics = Stores.Topic.list()
    render(conn, "index.json", topics: topics)
  end

  def create(conn, %{"topic" => params}) do
    with {:ok, %Topic{} = topic} <- Stores.Topic.create(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", topic_path(conn, :show, topic))
      |> render("show.json", topic: topic)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Stores.Topic.get!(id)
    render(conn, "show.json", topic: topic)
  end

  def update(conn, %{"id" => id, "topic" => params}) do
    topic = Stores.Topic.get!(id)

    with {:ok, %Topic{} = topic} <- Stores.Topic.update(topic, params) do
      render(conn, "show.json", topic: topic)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Stores.Topic.get!(id)

    with {:ok, %Topic{}} <- Stores.Topic.delete(topic) do
      send_resp(conn, :no_content, "")
    end
  end
end
