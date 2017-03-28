defmodule TheBestory.Store.Story
  alias TheBestory.Repo
  alias TheBestory.Schema.Story

  @doc """
  Return the list of stories.
  """
  def list, 
    do: Repo.all(Story)

  @doc """
  Get a single story.
  """
  def get(id), 
    do: Repo.get(Story, id)
  def get!(id), 
    do: Repo.get!(Story, id)

  @doc """
  Create a story.
  """
  def create(%{author: %User{} = author, topic: %Topic{} = topic} = attrs) do
    with {:ok, id} <- Snowflake.next_id() do
      %Story{}
      |> Repo.preload([:author, :topic])
      |> change
      |> put_assoc(:author, author)
      |> put_assoc(:topic, topic)
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Update a story.
  """
  def update(%Story{} = story, attrs \\ %{}) do
    refs = [:author, :topic]

    Enum.reduce(
      refs,
      story
      |> Repo.preload(refs)
      |> change,
      fn(ref, story) ->
      case Map.has_key?(attrs, ref) do
        true -> story |> put_assoc(ref, Map.get(attrs, ref))
           _ -> story
      end
    end)
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete a story.
  """
  def delete(%Story{} = story), 
    do: Repo.delete(story)


  defp change(%Story{} = story), 
    do: Ecto.Changeset.change(story)

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
    |> cast_assoc(:topic, [:required])
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
