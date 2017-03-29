defmodule TheBestory.API.Controller.Session do
  use TheBestory.API, :controller

  alias TheBestory.Store
  alias TheBestory.Utils.Password

  @fallback_controller Controller.Fallback

  plug :put_view, View.Session
  action_fallback @fallback_controller

  plug Guardian.Plug.EnsureAuthenticated, [handler: @fallback_controller] 
       when action in [:show, :update, :delete]
  plug Guardian.Plug.EnsureResource, [handler: @fallback_controller]
       when action in [:show, :update, :delete]

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    jwt = Guardian.Plug.current_token(conn)
    {_, claims} = Guardian.Plug.claims(conn)
    expired_at = Map.get(claims, "exp")

    render(conn, "show.json", session: %{
      jwt: jwt,
      expired_at: expired_at,
      user: user
    })
  end

  def create(conn, 
             %{"username" => username, "password" => password} = _params) do
    user = Store.User.get_by_username!(username)

    case Password.match(password, user.password) do
      true -> 
        conn = Guardian.Plug.api_sign_in(conn, user)
        jwt = Guardian.Plug.current_token(conn)
        {_, claims} = Guardian.Plug.claims(conn)
        expired_at = Map.get(claims, "exp")

        conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", Integer.to_string(expired_at))
        |> render("show.json", session: %{
             jwt: jwt,
             expired_at: expired_at,
             user: user
           })
      _ -> conn
        |> put_status(:bad_request)
        |> render(View.Error, "error.json", message: "Username or password is invalid")
    end
  end

  def update(conn, _params) do
    conn
    |> put_status(401)
    |> render(View.Error, "error.json", message: "Could not refresh!")
  end

  def delete(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    {_, claims} = Guardian.Plug.claims(conn)

    with :ok <- Guardian.revoke!(jwt, claims) do
      send_resp(conn, :no_content, "")
    end
  end
end
