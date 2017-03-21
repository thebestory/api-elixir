defmodule TheBestory.API.PostControllerTest do
  use TheBestory.API.ConnCase

  alias TheBestory.Schema.Post

  @create_attrs %{content: "some content", is_published: true, is_removed: true, published_at: %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"}, reactions_count: 42, replies_count: 42}
  @update_attrs %{content: "some updated content", is_published: false, is_removed: false, published_at: %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}, reactions_count: 43, replies_count: 43}
  @invalid_attrs %{content: nil, is_published: nil, is_removed: nil, published_at: nil, reactions_count: nil, replies_count: nil}

  def fixture(:post) do
    {:ok, post} = Post.create(@create_attrs)
    post
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates post and renders post when data is valid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, post_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "content" => "some content",
      "is_published" => true,
      "is_removed" => true,
      "published_at" => %DateTime{calendar: Calendar.ISO, day: 17, hour: 14, microsecond: {0, 6}, minute: 0, month: 4, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2010, zone_abbr: "UTC"},
      "reactions_count" => 42,
      "replies_count" => 42}
  end

  test "does not create post and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen post and renders post when data is valid", %{conn: conn} do
    %Post{id: id} = post = fixture(:post)
    conn = put conn, post_path(conn, :update, post), post: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, post_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "content" => "some updated content",
      "is_published" => false,
      "is_removed" => false,
      "published_at" => %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"},
      "reactions_count" => 43,
      "replies_count" => 43}
  end

  test "does not update chosen post and renders errors when data is invalid", %{conn: conn} do
    post = fixture(:post)
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen post", %{conn: conn} do
    post = fixture(:post)
    conn = delete conn, post_path(conn, :delete, post)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, post)
    end
  end
end
