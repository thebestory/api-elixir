defmodule TheBestory.API.PostController do
  use TheBestory.API, :controller

  alias TheBestory.Schema.Post

  action_fallback TheBestory.API.FallbackController

  def index(conn, _params) do
    posts = Post.list()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => params}) do
    with {:ok, %Post{} = post} <- Post.create(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", post_path(conn, :show, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Post.get!(id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => params}) do
    post = Post.get!(id)

    with {:ok, %Post{} = post} <- Post.update(post, params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Post.get!(id)

    with {:ok, %Post{}} <- Post.delete(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
