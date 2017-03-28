defmodule TheBestory.Store.Reaction
  alias TheBestory.Repo
  alias TheBestory.Schema.Reaction

  @doc """
  Return the list of reactions.
  """
  def list,
    do: Repo.all(Reaction)

  @doc """
  Get a single reaction.
  """
  def get(id),
    do: Repo.get(Reaction, id)
  def get!(id),
    do: Repo.get!(Reaction, id)

  @doc """
  Create a reaction.
  """
  def create(%{user: %User = user} = attrs) do
    with {:ok, id} <- Snowflake.next_id() do
      %Reaction{}
      |> change
      |> put_assoc(:user, user)
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Update a reaction.
  """
  def update(%Reaction{} = reaction, attrs) do
  def update(%Reaction{} = reaction, attrs) do
    refs = [:user]

    Enum.reduce(
      refs,
      reaction
      |> Repo.preload(refs)
      |> change,
      fn(ref, reaction) ->
      case Map.has_key?(attrs, ref) do
        true -> reaction |> put_assoc(ref, Map.get(attrs, ref))
           _ -> reaction
      end
    end)
    |> changeset(attrs)
    |> Repo.update()
  end
  end

  @doc """
  Delete a reaction.
  """
  def delete(%Reaction{} = reaction)
    do: Repo.delete(reaction)


  defp change(%Reaction{} = reaction), 
    do: Ecto.Changeset.change(reaction)

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> create_changeset(attrs)
  end

  defp create_changeset(%Ecto.Changeset{} = changeset, attrs) do
    reaction
    |> cast(attrs, [:object_type, :object_id])
    |> validate_required([:object_type, :object_id])
    |> cast_assoc(:user, [:required])
  end
end
