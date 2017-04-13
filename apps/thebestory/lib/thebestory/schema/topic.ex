defmodule TheBestory.Schema.Topic do
  use Ecto.Schema

  @primary_key {:id, :integer, []} # bigint # not for the changeset cast

  schema "topics" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :icon, :string

    field :stories_count, :integer

    field :is_active, :boolean
  end
end
