defmodule TheBestory.Repo.Migrations.Create.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :username, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end

end
