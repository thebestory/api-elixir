defmodule TheBestory.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :bigint, primary_key: true

      add :user_id, :bigint
      add :object_id, :bigint

      add :valid, :boolean

      add :added_at, :utc_datetime
      add :removed_at, :utc_datetime
    end

    create index(:reactions, [:user_id])
    create index(:reactions, [:object_id])
    create index(:reactions, [:valid])
  end
end
