defmodule TheBestory.Schema.User do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string

    field :reactions_count, :integer, default: 0
    field :stories_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    has_many :stories, Story

    timestamps()
  end
end
