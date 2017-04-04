defmodule TheBestory.Stores.Story do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.Topic
  alias TheBestory.Schema.User
  alias TheBestory.Stores

  @id_type "story"

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
      with {:ok, id} <- Stores.ID.generate(@id_type) do
        with {:ok, story} <- %Story{}
                             |> Repo.preload([:author, :topic])
                             |> change
                             |> put_assoc(:author, author)
                             |> put_assoc(:topic, topic)
                             |> changeset(attrs)
                             |> put_change(:id, id)
                             |> Repo.insert(),
             {:ok, _} <- Stores.User.increment_stories_count(author),
             {:ok, _} <- Stores.Topic.increment_stories_count(topic)
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
        # TODO: what we should to do with counters ???
        case Map.has_key?(attrs, ref) do
          true -> story |> put_assoc(ref, Map.get(attrs, ref))
             _ -> story
        end
      end
    )
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
      with {:ok, reaction} <- Stores.Reaction.create(%{
                                user: user,
                                object: story
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
  Add a comment to the story.
  """
  def add_comment(%{author: %User{} = author, 
                    story: %Story{} = story} = attrs) do
    attrs = attrs
            |> Map.put(:root, story)
            |> Map.put(:parent, story)

    Repo.transaction(fn ->
      with {:ok, comment} <- create(attrs),
           {:ok, _} <- increment_comments_count(story)
      do
        {:ok, comment}
      else
        _ -> Repo.rollback(:comment_not_created)
      end
    end)
  end

  @doc """
  Remove a user's reaction from the story.
  """
  def remove_reaction(%User{} = user, %Story{} = story),
    do: remove_reaction(story, user)
  def remove_reaction(%Story{} = story, %User{} = user) do
    # XXX: What if there is two+ (wtf) or zero valid reactions for user+object?
    with {:ok, reaction} <- Stores.Reaction.get_valid_by_user_and_object(user, story) do
      Repo.transaction(fn ->
        with {:ok, reaction} <- Stores.Reaction.invalidate(reaction),
             {:ok, _} <- decrement_reactions_count(story)
        do
          {:ok, reaction}
        else
          _ -> Repo.rollback(:reaction_not_invalidated)
        end
      end)
    end
  end

  @doc """
  Remove a comment from the story.
  """
  def remove_comment(%Comment{} = comment),
    do: Stores.Comment.delete(comment)

  @doc """
  Increment reactions count.
  """
  def increment_reactions_count(%Story{} = story) do
    story
    |> change
    |> changeset(%{reactions_count: story.reactions_count + 1})
    |> Repo.update()
  end

  @doc """
  Increment comments count.
  """
  def increment_comments_count(%Story{} = story) do
    story
    |> change
    |> changeset(%{comments_count: story.comments_count + 1})
    |> Repo.update()
  end

  @doc """
  Decrement reactions count.
  """
  def decrement_reactions_count(%Story{} = story) do
    story
    |> change
    |> changeset(%{reactions_count: story.reactions_count - 1})
    |> Repo.update()
  end

  @doc """
  Decrement comments count.
  """
  def decrement_comments_count(%Story{} = story) do
    story
    |> change
    |> changeset(%{comments_count: story.comments_count - 1})
    |> Repo.update()
  end

  @doc """
  Delete a story.
  """
  def delete(%Story{} = story) do
    # We don't decrement user's stories counter, because this story still
    # displayed in the user's history of stories
    story
    |> change
    |> changeset(%{is_removed: true})
    |> Repo.update()
  end


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
      %Ecto.Changeset{valid?: true, data: story, changes: %{content: _}} ->
        case story.id do
          nil -> changeset
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
