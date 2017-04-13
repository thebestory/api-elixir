defmodule TheBestory.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:stories, primary_key: false) do
      add :id, :bigint, primary_key: true

      add :author_id, :bigint
      add :topic_id, :bigint

      add :content, :text

      add :comments_count, :integer
      add :reactions_count, :integer

      add :is_published, :boolean
      add :is_removed, :boolean

      add :submitted_at, :utc_datetime
      add :published_at, :utc_datetime
      add :edited_at, :utc_datetime
    end

    create index(:stories, [:author_id])
    create index(:stories, [:topic_id])
  end
end
