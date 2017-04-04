defmodule TheBestory.Schema.ID do
  use Ecto.Schema

  @primary_key {:id, :string, []}

  schema "ids" do
    field :type, :string
  end
end
