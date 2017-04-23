defmodule TheBestory.API.Controller.User do
  use TheBestory.API, :controller

  alias TheBestory.Schema.User
  alias TheBestory.Stores

  @fallback_controller Controller.Fallback

  plug :put_view, View.User
  action_fallback @fallback_controller

  plug Guardian.Plug.EnsureAuthenticated, [handler: @fallback_controller] 
       when action in [:create, :update, :delete]
  plug Guardian.Plug.EnsureResource, [handler: @fallback_controller]
       when action in [:create, :update, :delete]

  def create(conn, %{"user" => params}) do
    with {:ok, %User{} = user} <- Stores.User.create(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Stores.User.get!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    user = Stores.User.get!(id)

    with {:ok, %User{} = user} <- Stores.User.update(user, params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Stores.User.get!(id)

    with {:ok, %User{}} <- Stores.User.delete(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
