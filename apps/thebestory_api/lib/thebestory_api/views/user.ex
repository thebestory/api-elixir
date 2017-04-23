defmodule TheBestory.API.View.User do
  use TheBestory.API, :view
  
  alias TheBestory.API.View

  def render("index.json", %{users: users}), do: %{
    data: render_many(users, View.User, "user.json")
  }

  def render("show.json", %{user: user}), do: %{
    data: render_one(user, View.User, "user.json")
  }

  def render("user.json", %{user: user}), do: %{
    id: user.id,
    username: user.username,
    comments_count: user.comments_count,
    reactions_count: user.reactions_count,
    stories_count: user.stories_count
  }
end
