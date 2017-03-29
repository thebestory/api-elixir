defmodule TheBestory.API.View.Session do
  use TheBestory.API, :view

  def render("index.json", %{sessions: sessions}), do: %{
    data: render_many(sessions, View.Session, "session.json")
  }

  def render("show.json", %{session: session}), do: %{
    data: render_one(session, View.Session, "session.json")
  }

  def render("session.json", %{session: session}), do: %{
    jwt: session.jwt,
    expired_at: session.expired_at,
    user: render_one(session.user, View.User, "user.json")
  }
end
