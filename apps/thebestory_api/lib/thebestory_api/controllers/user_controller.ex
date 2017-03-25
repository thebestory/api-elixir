defmodule TheBestory.API.UserController do
  use TheBestory.API, :controller

  alias TheBestory.Schema.User

  action_fallback TheBestory.API.FallbackController

  def create(conn, %{"user" => params}) do
    with {:ok, %User{} = user} <- User.register(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = User.get!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    user = User.get!(id)

    with {:ok, %User{} = user} <- User.update(user, params) do
      render(conn, "show.json", user: user)
    end
  end
end
