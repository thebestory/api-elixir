defmodule TheBestory.API.Controller.Fallback do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TheBestory.API, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(View.Error, :error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(View.Error, :"404")
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> render(View.Error, :"500")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(View.Error, :error, message: "Authentication required")
  end

  def no_resource(conn, _params) do
    conn
    |> put_status(401)
    |> render(View.Error, :error, message: "Authentication required")
  end
end
