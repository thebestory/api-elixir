defmodule TheBestory.API.View.Story do
  use TheBestory.API, :view

  alias TheBestory.Schema.Topic
  alias TheBestory.Schema.User

  def render("index.json", %{stories: stories}), do: %{
    data: render_many(stories, View.Story, "story.json")
  }

  def render("show.json", %{story: story}), do: %{
    data: render_one(story, View.Story, "story.json")
  }

  def render("story.json", %{story: story}), do: %{
    id: story.id,
    author: render_author(story.author_id, story.author),
    topic: render_topic(story.topic_id, story.topic),
    content: story.content,
    likes_count: story.reactions_count,
    comments_count: story.comments_count,
    is_published: story.is_published,
    is_removed: story.is_removed,
    published_at: story.published_at,
    submitted_at: story.inserted_at,
    edited_at: story.edited_at
  }

  defp render_author(_id, %User{} = author),
    do: render_one(author, View.User, "user.json")
  defp render_author(id, _author), do: %{
    id: id
  }

  defp render_topic(_id, %Topic{} = topic),
    do: render_one(topic, View.Topic, "topic.json")
  defp render_topic(id, _topic), do: %{
    id: id
  }
end
