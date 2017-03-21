defmodule TheBestory.Web.PostView do
  use TheBestory.Web, :view
  alias TheBestory.Web.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{id: post.id,
      topic_id: post.topic_id,
      content: post.content,
      reactions_count: post.reactions_count,
      replies_count: post.replies_count,
      is_published: post.is_published,
      is_removed: post.is_removed,
      published_at: post.published_at,
      submitted_at: post.inserted_at,
      edited_at: post.edited_at}
  end
end
