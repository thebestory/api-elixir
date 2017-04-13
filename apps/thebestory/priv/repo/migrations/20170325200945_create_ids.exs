defmodule TheBestory.Repo.Migrations.CreateIds do
  use Ecto.Migration

  def change do
    create table(:ids, primary_key: false) do
      add :id, :bigint, primary_key: true
      add :type, :string
    end
  end

end
