defmodule TheBestory.Schema.Reaction do
  use Ecto.Schema

  @primary_key {:id, :integer, []} # bigint # not for the changeset cast

  schema "reactions" do
    field :user_id, :integer # bigint
    field :object_id, :integer # bigint

    field :valid, :boolean

    field :added_at, :utc_datetime
    field :removed_at, :utc_datetime
  end
end
