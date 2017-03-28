defmodule TheBestory.Schema.Comment do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "comments" do
    field :content, :string
    
    field :reactions_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false

    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime

    belongs_to :author, User, type: :string
    belongs_to :story, Story, type: :string
    belongs_to :parent, Comment, type: :string

    timestamps()
  end
end
