defmodule TheBestory.Stores.UserTest do
  use TheBestory.DataCase

  alias TheBestory.Stores
  alias TheBestory.Utils.Password

  @test_user %{
    username: "test",
    email: "test@thebestory.com",
    password: "password"
  }

  test "get/1 returns the user by the given id" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get(user.id) == user
  end

  test "get!/1 returns the user by the given id" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get!(user.id) == user
  end

  test "get_by_username/1 returns the user by the given username" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get_by_username(user.username) == user
  end

  test "get_by_username!/1 returns the user by the given username" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get_by_username!(user.username) == user
  end

  test "get_by_email/1 returns the user by the given email" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get_by_email(user.email) == user
  end

  test "get_by_email!/1 returns the user by the given email" do
    {:ok, user} = Stores.User.create(@test_user)
    assert Stores.User.get_by_email!(user.email) == user
  end

  test "create/1 creates a user" do
    {:ok, user} = Stores.User.create(@test_user)

    assert !is_nil(user.id)
    assert user.username == @test_user.username
    assert user.email == @test_user.email
    assert Password.match(@test_user.password, user.password)
    assert user.comments_count == 0
    assert user.reactions_count == 0
    assert user.stories_count == 0
    assert !is_nil(user.registered_at)
  end

  test "create/1 can create a user with custom counters" do
    {:ok, user} = 
      @test_user
      |> Map.put(:comments_count, 2)
      |> Map.put(:reactions_count, 4)
      |> Map.put(:stories_count, 7)
      |> Stores.User.create()

    assert user.comments_count == 2
    assert user.reactions_count == 4
    assert user.stories_count == 7
  end
end
