defmodule TheBestory.Schema.Topic do
  use Ecto.Schema

  alias TheBestory.Schema.Post

  @primary_key {:id, :string, []}

  schema "topics" do
    field :description, :string, default: ""
    field :icon, :string, default: ""
    field :is_active, :boolean, default: false
    field :slug, :string
    field :posts_count, :integer, default: 0
    field :title, :string

    has_many :posts, Post

    timestamps()
  end
end
