defmodule TheBestory.Schema.Post do
  use Ecto.Schema

  alias TheBestory.Schema.Topic

  @primary_key {:id, :string, []}

  schema "posts" do
    field :content, :string
    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false
    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime
    field :reactions_count, :integer, default: 0
    field :replies_count, :integer, default: 0

    belongs_to :topic, Topic, type: :string

    timestamps()
  end
end
