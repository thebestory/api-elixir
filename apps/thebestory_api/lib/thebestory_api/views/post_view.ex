defmodule TheBestory.API.PostView do
  use TheBestory.API, :view

  alias TheBestory.Schema.Post
  alias TheBestory.Schema.Topic
  alias TheBestory.API.PostView
  alias TheBestory.API.TopicView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    p = %{
      id: post.id,
      topic: %{
        id: post.topic_id
      },
      content: post.content,
      reactions_count: post.reactions_count,
      replies_count: post.replies_count,
      is_published: post.is_published,
      is_removed: post.is_removed,
      published_at: post.published_at,
      submitted_at: post.inserted_at,
      edited_at: post.edited_at
    }

    case post.topic do
      %Topic{} -> 
        Map.put(p, :topic, render_one(post.topic, TopicView, "topic.json"))
      _ -> p
    end
  end
end
