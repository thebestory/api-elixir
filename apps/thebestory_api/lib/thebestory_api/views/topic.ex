defmodule TheBestory.API.View.Topic do
  use TheBestory.API, :view

  def render("index.json", %{topics: topics}), do: %{
    data: render_many(topics, View.Topic, "topic.json")
  }

  def render("show.json", %{topic: topic}), do: %{
    data: render_one(topic, View.Topic, "topic.json")
  }

  def render("topic.json", %{topic: topic}), do: %{
    id: topic.id,
    slug: topic.slug,
    title: topic.title,
    description: topic.description,
    icon: topic.icon,
    stories_count: topic.stories_count,
    is_active: topic.is_active
  }
end
