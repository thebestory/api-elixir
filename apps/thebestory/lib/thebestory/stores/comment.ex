defmodule TheBestory.Store.Comment
  alias TheBestory.Repo
  alias TheBestory.Schema.Comment

  @doc """
  Return the list of comments.
  """
  defp list do
    Repo.all(Comment)
  end

  @doc """
  Get a single comment.
  """
  def get(id), do: Repo.get(Comment, id)
  def get!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.
  """
  def create(%{author: %User{} = author, story: %Story{} = story, 
               parent: %Comment{} = parent} = attrs) do
    with {:ok, id} <- Snowflake.next_id() do
      %Comment{}
      |> Repo.preload([:author, :story, :parent])
      |> change
      |> put_assoc(:author, author)
      |> put_assoc(:story, story)
      |> put_assoc(:parent, parent)
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end
  def create(%{author: %User{} = author, story: %Story{} = story} = attrs) do
    with {:ok, id} <- Snowflake.next_id() do
      %Comment{}
      |> Repo.preload([:author, :story])
      |> change
      |> put_assoc(:author, author)
      |> put_assoc(:story, story)
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a comment.
  """
  def update(%Comment{} = comment, attrs \\ %{}) do
    Enum.reduce([:author, :story, :parent], comment |> change,
                fn(ref, comment) ->
      case Map.has_key?(attrs, ref) do
        true -> comment
                |> Repo.preload([ref])
                |> put_assoc(ref, Map.get(attrs, ref))
        _ -> comment
      end
    end)
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a comment.
  """
  def delete(%Comment{} = comment) do
    Repo.delete(comment)
  end

  defp change(%Comment{} = comment), 
    do: Ecto.Changeset.change(comment)

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> public_changeset(attrs)
    |> create_changeset(attrs)
    |> moderation_changeset(attrs)
    |> counters_changeset(attrs)
  end

  defp public_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end

  defp create_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast_assoc(:author, [:required])
    |> cast_assoc(:story, [:required])
    |> cast_assoc(:parent)
  end

  defp moderation_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:is_published, :is_removed])
    |> validate_required([:is_published, :is_removed])
  end

  defp counters_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:reactions_count, :comments_count])
    |> validate_required([:reactions_count, :comments_count])
    |> validate_number(:reactions_count, greater_than_or_equal_to: 0)
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
  end
end
