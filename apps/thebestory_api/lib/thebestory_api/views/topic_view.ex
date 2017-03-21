defmodule TheBestory.API.TopicView do
  use TheBestory.API, :view
  alias TheBestory.API.TopicView

  def render("index.json", %{topics: topics}) do
    %{data: render_many(topics, TopicView, "topic.json")}
  end

  def render("show.json", %{topic: topic}) do
    %{data: render_one(topic, TopicView, "topic.json")}
  end

  def render("topic.json", %{topic: topic}) do
    %{id: topic.id,
      slug: topic.slug,
      title: topic.title,
      description: topic.description,
      icon: topic.icon,
      is_active: topic.is_active,
      posts_count: topic.posts_count}
  end
end
