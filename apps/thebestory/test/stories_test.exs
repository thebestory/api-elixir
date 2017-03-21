defmodule TheBestory.SchemaTest do
  use TheBestory.DataCase

  alias TheBestory.Schema
  alias TheBestory.Schema.Topic

  @create_attrs %{description: "some description", icon: "some icon", is_active: true, slug: "some slug", posts_count: 42, title: "some title"}
  @update_attrs %{description: "some updated description", icon: "some updated icon", is_active: false, slug: "some updated slug", posts_count: 43, title: "some updated title"}
  @invalid_attrs %{description: nil, icon: nil, is_active: nil, slug: nil, posts_count: nil, title: nil}

  def fixture(:topic, attrs \\ @create_attrs) do
    {:ok, topic} = Schema.create_topic(attrs)
    topic
  end

  test "list_topics/1 returns all topics" do
    topic = fixture(:topic)
    assert Schema.list_topics() == [topic]
  end

  test "get_topic! returns the topic with given id" do
    topic = fixture(:topic)
    assert Schema.get_topic!(topic.id) == topic
  end

  test "create_topic/1 with valid data creates a topic" do
    assert {:ok, %Topic{} = topic} = Schema.create_topic(@create_attrs)
    assert topic.description == "some description"
    assert topic.icon == "some icon"
    assert topic.is_active == true
    assert topic.slug == "some slug"
    assert topic.posts_count == 42
    assert topic.title == "some title"
  end

  test "create_topic/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Schema.create_topic(@invalid_attrs)
  end

  test "update_topic/2 with valid data updates the topic" do
    topic = fixture(:topic)
    assert {:ok, topic} = Schema.update_topic(topic, @update_attrs)
    assert %Topic{} = topic
    assert topic.description == "some updated description"
    assert topic.icon == "some updated icon"
    assert topic.is_active == false
    assert topic.slug == "some updated slug"
    assert topic.posts_count == 43
    assert topic.title == "some updated title"
  end

  test "update_topic/2 with invalid data returns error changeset" do
    topic = fixture(:topic)
    assert {:error, %Ecto.Changeset{}} = Schema.update_topic(topic, @invalid_attrs)
    assert topic == Schema.get_topic!(topic.id)
  end

  test "delete_topic/1 deletes the topic" do
    topic = fixture(:topic)
    assert {:ok, %Topic{}} = Schema.delete_topic(topic)
    assert_raise Ecto.NoResultsError, fn -> Schema.get_topic!(topic.id) end
  end

  test "change_topic/1 returns a topic changeset" do
    topic = fixture(:topic)
    assert %Ecto.Changeset{} = Schema.change_topic(topic)
  end
end
