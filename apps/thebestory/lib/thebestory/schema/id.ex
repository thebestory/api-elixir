defmodule TheBestory.Schema.ID do
  use Ecto.Schema

  @primary_key {:id, :integer, []} # bigint # not for the changeset cast

  schema "ids" do
    field :type, :string
  end
end
