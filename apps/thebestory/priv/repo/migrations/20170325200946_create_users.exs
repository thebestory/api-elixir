defmodule TheBestory.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :bigint, primary_key: true

      add :username, :string
      add :email, :string
      add :password, :string

      add :comments_count, :integer
      add :reactions_count, :integer
      add :stories_count, :integer

      add :registered_at, :utc_datetime
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end

end
