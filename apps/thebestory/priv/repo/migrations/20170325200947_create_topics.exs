defmodule TheBestory.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :bigint, primary_key: true

      add :title, :string
      add :slug, :string
      add :description, :text
      add :icon, :string

      add :stories_count, :integer

      add :is_active, :boolean
    end

  end
end
