defmodule TheBestory.Schema.Story do
  use Ecto.Schema

  alias TheBestory.Schema.Topic
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "stories" do
    field :content, :string
    
    field :reactions_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false

    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime

    belongs_to :author, User, type: :string
    belongs_to :topic, Topic, type: :string

    timestamps()
  end
end
