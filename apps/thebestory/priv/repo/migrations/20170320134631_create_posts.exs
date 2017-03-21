defmodule TheBestory.Repo.Migrations.Create.Posts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :string, primary_key: true
      add :content, :text, null: false
      add :reactions_count, :integer, default: 0, null: false
      add :replies_count, :integer, default: 0, null: false
      add :is_published, :boolean, default: false, null: false
      add :is_removed, :boolean, default: false, null: false
      add :published_at, :utc_datetime, null: true
      add :edited_at, :utc_datetime, null: true
      add :topic_id, references(:topics, type: :string, on_delete: :nothing, null: false)

      timestamps()
    end

    create index(:posts, [:topic_id])
  end
end
