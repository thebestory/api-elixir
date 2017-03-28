defmodule TheBestory.API.UserController do
  use TheBestory.API, :controller

  alias TheBestory.Schema
  alias TheBestory.Store

  action_fallback TheBestory.API.FallbackController

  def create(conn, %{"user" => params}) do
    with {:ok, %Schema.User{} = user} <- Store.User.register(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Store.User.get!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    user = Store.User.get!(id)

    with {:ok, %User{} = user} <- Store.User.update_parameters(user, params) do
      render(conn, "show.json", user: user)
    end
  end
end
