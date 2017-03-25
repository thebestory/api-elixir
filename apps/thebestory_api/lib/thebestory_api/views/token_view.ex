defmodule TheBestory.API.TokenView do
  use TheBestory.API, :view
  alias TheBestory.API.TokenView
  alias TheBestory.API.UserView

  def render("index.json", %{tokens: tokens}) do
    %{data: render_many(tokens, TokenView, "token.json")}
  end

  def render("show.json", %{token: token}) do
    %{data: render_one(token, TokenView, "token.json")}
  end

  def render("token.json", %{token: token}) do
    %{jwt: token.jwt,
      exp: token.exp,
      user: render_one(token.user, UserView, "show.json")}
  end
end
