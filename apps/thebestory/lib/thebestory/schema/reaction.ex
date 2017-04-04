defmodule TheBestory.Schema.Reaction do
  use Ecto.Schema

  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "reactions" do
    field :user_id, :string
    field :object_id, :string

    field :valid, :boolean, default: true

    belongs_to :user, User, type: :string, define_field: :false

    timestamps()
  end
end
