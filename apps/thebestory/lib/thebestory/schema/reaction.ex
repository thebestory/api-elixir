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

  @doc """
  Returns the list of reactions.
  """
  defp list do
    Repo.all(Reaction)
  end

  @doc """
  Gets a single reaction.
  """
  def get(id), do: Repo.get(Reaction, id)
  def get!(id), do: Repo.get!(Reaction, id)

  @doc """
  Creates a reaction.
  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Reaction{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a reaction.
  """
  def update(%Reaction{} = reaction, attrs) do
    reaction
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reaction.
  """
  def delete(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reaction changes.
  """
  def change(%Reaction{} = reaction) do
    changeset(reaction, %{})
  end

  defp changeset(%Reaction{} = reaction, attrs) do
    reaction
    |> cast(attrs, [:object_type, :object_id])
    |> validate_required([:object_type, :object_id])
    |> cast_assoc(:user, [:required])
  end
end
