defmodule TheBestory.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :bigint, primary_key: true
      
      add :author_id, :bigint
      add :root_id, :bigint
      add :parent_id, :bigint

      add :content, :text

      add :comments_count, :integer
      add :reactions_count, :integer

      add :is_published, :boolean
      add :is_removed, :boolean

      add :submitted_at, :utc_datetime
      add :published_at, :utc_datetime
      add :edited_at, :utc_datetime
    end

    create index(:comments, [:author_id])
    create index(:comments, [:root_id])
    create index(:comments, [:parent_id])
  end
end
