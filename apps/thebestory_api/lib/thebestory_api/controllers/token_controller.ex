defmodule TheBestory.API.TokenController do
  use TheBestory.API, :controller

  alias TheBestory.Schema.User

  action_fallback TheBestory.API.FallbackController

  def create(conn, %{"token" => %{"grant_type" => grant_type} = params}) do
    case grant_type do
      "password" -> password_token(conn, params)
      "refresh" -> refresh_token(conn, params)
      _ -> {:error, :not_found}
    end
  end

  defp password_token(conn, %{"username" => username, "password" => password}) do
      user = User.get_by_username!(username)

      case User.match_password(password, user.password) do
        true -> 
          conn = Guardian.Plug.api_sign_in(conn, user)
          jwt = Guardian.Plug.current_token(conn)
          {_, claims} = Guardian.Plug.claims(conn)
          exp = Map.get(claims, "exp")

          conn
          |> put_resp_header("authorization", "Bearer #{jwt}")
          |> put_resp_header("x-expires", Integer.to_string(exp))
          |> render("token.json", token: %{user: user, jwt: jwt, exp: exp})
        _ -> conn
          |> put_status(401)
          |> render("error.json", message: "Could not login")
      end
  end

  defp refresh_token(conn, params) do
    conn
    |> put_status(401)
    |> render("error.json", message: "Could not refresh")
  end

  def delete(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    claims = Guardian.Plug.claims(conn)

    Guardian.revoke!(jwt, claims)

    send_resp(conn, :no_content, "")
  end
end
