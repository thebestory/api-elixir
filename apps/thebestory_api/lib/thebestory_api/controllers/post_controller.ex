defmodule TheBestory.API.PostController do
  use TheBestory.API, :controller

  alias TheBestory.Schema
  alias TheBestory.Schema.Post

  action_fallback TheBestory.API.FallbackController

  def index(conn, _params) do
    posts = Schema.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => post_params}) do
    with {:ok, %Post{} = post} <- Schema.create_post(post_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", post_path(conn, :show, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Schema.get_post!(id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Schema.get_post!(id)

    with {:ok, %Post{} = post} <- Schema.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Schema.get_post!(id)
    with {:ok, %Post{}} <- Schema.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
