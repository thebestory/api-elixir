defmodule TheBestory.Repo.Migrations.Create.Reactions do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :string, primary_key: true

      add :user_id, references(:users, type: :string, on_delete: :nothing, null: false)
      
      add :object_type, :string, null: false
      add :object_id, :string, null: false

      timestamps()
    end
  end
end
