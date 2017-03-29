defmodule TheBestory.Store.Story do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.Topic
  alias TheBestory.Schema.User
  alias TheBestory.Store

  @reaction_object_type "story"

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
    Repo.transaction(fn ->
      with {:ok, id} <- Snowflake.next_id() do
        with {:ok, story} <- %Story{}
                             |> Repo.preload([:author, :topic])
                             |> change
                             |> put_assoc(:author, author)
                             |> put_assoc(:topic, topic)
                             |> changeset(attrs)
                             |> put_change(:id, Integer.to_string(id))
                             |> Repo.insert(),
             {:ok, _} <- Store.User.increment_stories_count(author),
             {:ok, _} <- Store.Topic.increment_stories_count(topic)
        do
          {:ok, story}
        else
          _ -> Repo.rollback(:story_not_created)
        end
      else
        _ -> Repo.rollback(:id_not_generated)
      end
    end)
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
          true -> story |> put_assoc(ref, Map.get(attrs, ref))  # TODO: increment/decrement values for old/new ref
             _ -> story
        end
    end)
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Add a user's reaction to the story.
  """
  def add_reaction(%User{} = user, %Story{} = story),
    do: add_reaction(story, user)
  def add_reaction(%Story{} = story, %User{} = user) do
    Repo.transaction(fn ->
      with {:ok, reaction} <- Store.Reaction.create(%{
                                object_type: @reaction_object_type,
                                object_id: story.id,
                                user: user
                              }),
           {:ok, _} <- increment_reactions_count(story)
      do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Increment reactions count.
  """
  def increment_reactions_count(%Story{} = story) do
    story
    |> change
    |> counters_changeset(%{reactions_count: story.reactions_count + 1})
    |> Repo.update()
  end

  @doc """
  Increment comments count.
  """
  def increment_comments_count(%Story{} = story) do
    story
    |> change
    |> counters_changeset(%{comments_count: story.comments_count + 1})
    |> Repo.update()
  end

  @doc """
  Decrement reactions count.
  """
  def decrement_reactions_count(%Story{} = story) do
    story
    |> change
    |> counters_changeset(%{reactions_count: story.reactions_count - 1})
    |> Repo.update()
  end

  @doc """
  Decrement comments count.
  """
  def decrement_comments_count(%Story{} = story) do
    story
    |> change
    |> counters_changeset(%{comments_count: story.comments_count - 1})
    |> Repo.update()
  end

  @doc """
  Delete a story.
  """
  def delete(%Story{} = story), 
    do: Repo.delete(story)


  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> public_changeset(attrs)
    |> create_changeset(attrs)
    |> moderation_changeset(attrs)
    |> counters_changeset(attrs)
    |> put_published_datetime
    |> put_edited_datetime
  end

  defp public_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end

  defp create_changeset(%Ecto.Changeset{} = changeset, _attrs) do
    changeset
    |> validate_required([:author, :topic])
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

  defp put_published_datetime(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{is_published: is_published}} ->
        case is_published do
          true -> put_change(changeset, :published_at, DateTime.utc_now())
             _ -> changeset
        end
      _ -> changeset
    end
  end

  defp put_edited_datetime(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, data: story} ->
        case story.id do
          nil -> changeset
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
