defmodule TheBestory.Schema.Reaction do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.Reaction
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "reactions" do
    field :object_type, :string
    field :object_id, :string

    belongs_to :user, User, type: :string
  end
end
