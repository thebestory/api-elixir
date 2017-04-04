defmodule TheBestory.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :string, primary_key: true

      add :user_id, :string, null: false
      add :object_id, :string, null: false

      add :valid, :boolean, default: true, null: false

      timestamps()
    end

    create index(:reactions, [:user_id])
    create index(:reactions, [:object_id])
    create index(:reactions, [:valid])
  end
end
