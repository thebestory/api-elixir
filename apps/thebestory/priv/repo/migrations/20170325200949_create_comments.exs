defmodule TheBestory.Repo.Migrations.Create.Comments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :string, primary_key: true
      
      add :content, :text, null: false

      add :reactions_count, :integer, default: 0, null: false
      add :comments_count, :integer, default: 0, null: false

      add :is_published, :boolean, default: true, null: false
      add :is_removed, :boolean, default: false, null: false

      add :published_at, :utc_datetime, null: true
      add :edited_at, :utc_datetime, null: true

      add :author_id, references(:users, type: :string, on_delete: :nothing, null: false)
      add :story_id, references(:stories, type: :string, on_delete: :nothing, null: false)
      add :parent_id, references(:comments, type: :string, on_delete: :nothing, null: true)

      timestamps()
    end

    create index(:comments, [:author_id])
    create index(:comments, [:topic_id])
    create index(:comments, [:parent_id])
  end
end
