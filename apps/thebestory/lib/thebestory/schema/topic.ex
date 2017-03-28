defmodule TheBestory.Schema.Topic do
  use Ecto.Schema

  alias TheBestory.Schema.Story
  alias TheBestory.Schema.Topic

  @primary_key {:id, :string, []}

  schema "topics" do
    field :title, :string
    field :slug, :string
    field :description, :string, default: ""
    field :icon, :string, default: ""

    field :stories_count, :integer, default: 0

    field :is_active, :boolean, default: false

    has_many :stories, Story

    timestamps()
  end
end
