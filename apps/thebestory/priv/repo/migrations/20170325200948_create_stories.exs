defmodule TheBestory.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:stories, primary_key: false) do
      add :id, :string, primary_key: true

      add :content, :text, null: false

      add :reactions_count, :integer, default: 0, null: false
      add :comments_count, :integer, default: 0, null: false

      add :is_published, :boolean, default: false, null: false
      add :is_removed, :boolean, default: false, null: false

      add :published_at, :utc_datetime, null: true
      add :edited_at, :utc_datetime, null: true

      add :author_id, :string, null: false
      add :topic_id, :string, null: false

      timestamps()
    end

    create index(:stories, [:author_id])
    create index(:stories, [:topic_id])
  end
end
