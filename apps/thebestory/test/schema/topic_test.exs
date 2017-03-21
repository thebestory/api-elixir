defmodule TheBestory.Schema.TopicTest do
  use TheBestory.DataCase

  alias TheBestory.Schema.Topic

  @create_attrs %{description: "some description", icon: "some icon", is_active: true, slug: "some slug", posts_count: 42, title: "some title"}
  @update_attrs %{description: "some updated description", icon: "some updated icon", is_active: false, slug: "some updated slug", posts_count: 43, title: "some updated title"}
  @invalid_attrs %{description: nil, icon: nil, is_active: nil, slug: nil, posts_count: nil, title: nil}

  def fixture(:topic, attrs \\ @create_attrs) do
    {:ok, topic} = Topic.create(attrs)
    topic
  end

  test "list/1 returns all topics" do
    topic = fixture(:topic)
    assert Topic.list() == [topic]
  end

  test "get! returns the topic with given id" do
    topic = fixture(:topic)
    assert Topic.get!(topic.id) == topic
  end

  test "create/1 with valid data creates a topic" do
    assert {:ok, %Topic{} = topic} = Topic.create(@create_attrs)
    assert topic.description == "some description"
    assert topic.icon == "some icon"
    assert topic.is_active == true
    assert topic.slug == "some slug"
    assert topic.posts_count == 42
    assert topic.title == "some title"
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Topic.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the topic" do
    topic = fixture(:topic)
    assert {:ok, topic} = Topic.update(topic, @update_attrs)
    assert %Topic{} = topic
    assert topic.description == "some updated description"
    assert topic.icon == "some updated icon"
    assert topic.is_active == false
    assert topic.slug == "some updated slug"
    assert topic.posts_count == 43
    assert topic.title == "some updated title"
  end

  test "update/2 with invalid data returns error changeset" do
    topic = fixture(:topic)
    assert {:error, %Ecto.Changeset{}} = Topic.update(topic, @invalid_attrs)
    assert topic == Topic.get!(topic.id)
  end

  test "delete/1 deletes the topic" do
    topic = fixture(:topic)
    assert {:ok, %Topic{}} = Topic.delete(topic)
    assert_raise Ecto.NoResultsError, fn -> Topic.get!(topic.id) end
  end

  test "change/1 returns a topic changeset" do
    topic = fixture(:topic)
    assert %Ecto.Changeset{} = Topic.change(topic)
  end
end
