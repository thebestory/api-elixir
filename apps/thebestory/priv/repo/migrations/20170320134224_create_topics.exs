defmodule TheBestory.Repo.Migrations.Create.Topics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :string, primary_key: true
      add :slug, :string, null: false
      add :title, :string, null: false
      add :description, :text, default: "", null: false
      add :icon, :string, default: "", null: false
      add :is_active, :boolean, default: true, null: false
      add :posts_count, :integer, default: 0, null: false

      timestamps()
    end

  end
end
