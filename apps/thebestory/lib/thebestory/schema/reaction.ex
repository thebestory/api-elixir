defmodule TheBestory.Schema.Reaction do
  use Ecto.Schema

  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "reactions" do
    field :object_type, :string
    field :object_id, :string

    belongs_to :user, User, type: :string
  end
end
