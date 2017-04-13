defmodule TheBestory.Schema.Comment do
  use Ecto.Schema

  @primary_key {:id, :integer, []} # bigint # not for the changeset cast

  schema "comments" do
    field :author_id, :integer # bigint
    field :root_id, :integer # bigint # not for the changeset cast
    field :parent_id, :integer # bigint # not for the changeset cast

    field :content, :string

    field :comments_count, :integer
    field :reactions_count, :integer

    field :is_published, :boolean
    field :is_removed, :boolean

    field :submitted_at, :utc_datetime # not for the changeset cast
    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime # not for the changeset cast
  end
end
