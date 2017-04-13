defmodule TheBestory.Schema.User do
  use Ecto.Schema

  @primary_key {:id, :integer, []} # bigint # not for the changeset cast

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string

    field :comments_count, :integer
    field :reactions_count, :integer
    field :stories_count, :integer

    field :registered_at, :utc_datetime # not for the changeset cast
  end
end
