defmodule TheBestory.Stores.Story do
  import Ecto.Changeset, warn: false

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
      with {:ok, id}    <- Stores.ID.generate(@id_type),
           {:ok, story} <- %Story{}
                           |> changeset(%{
                             comments_count: 0,
                             reactions_count: 0,
                             is_published: false,
                             is_removed: false
                           })
                           |> changeset(attrs)
                           |> changeset(%{
                             author_id: author.id,
                             topic_id: topic.id
                           })
                           |> put_change(:id, id)
                           |> put_change(:submitted_at, DateTime.utc_now())
                           |> changeset()
                           |> Repo.insert(),
           {:ok, _}     <- Stores.User.increment_stories_count(author),
           {:ok, _}     <- Stores.Topic.increment_stories_count(topic)
      do
        story
      else
        _ -> Repo.rollback(:story_not_created)
      end
    end)
  end

  @doc """
  Update the story.
  """
  def update(%Story{} = story, attrs \\ %{}) do
    Repo.transaction(fn ->
      chngst = changeset(story, attrs)

      # TODO: 

      # if Map.has_key?(attrs, :author) and 
      #    story.author_id != Map.get(attrs, :author).id
      # do
      #   with {:ok, old} <- Stores.User.get(story.author_id),
      #        {:ok, new} <- Stores.User.get(Map.get(attrs, :author).id),
      #        {:ok, _}   <- Stores.User.decrement_stories_count(old),
      #        {:ok, _}   <- Stores.User.increment_stories_count(new)
      #   do
      #     chngst = changeset(chngst, %{author_id: new.id})
      #   else
      #     _ -> Repo.rollback(:story_not_updated)
      #   end
      # end

      if Map.has_key?(attrs, :topic) and 
         story.topic_id != Map.get(attrs, :topic).id
      do
        with {:ok, old} <- Stores.Topic.get(story.topic_id),
             {:ok, new} <- Stores.Topic.get(Map.get(attrs, :topic).id),
             {:ok, _}   <- Stores.Topic.decrement_stories_count(old),
             {:ok, _}   <- Stores.Topic.increment_stories_count(new)
        do
          chngst = changeset(chngst, %{topic_id: new.id})
          Repo.update(chngst)
        else
          _ -> Repo.rollback(:story_not_updated)
        end
      else
        Repo.update(chngst)
      end
    end)
  end

  @doc """
  Add a comment to the story.
  """
  def add_comment(%{author: %User{} = _author, 
                    story: %Story{} = story} = attrs) do
    attrs = attrs
            |> Map.put(:root, story)
            |> Map.put(:parent, story)

    Repo.transaction(fn ->
      with {:ok, comment} <- Stores.Comment.create(attrs),
           {:ok, _}       <- increment_comments_count(story)
      do
        comment
      else
        _ -> Repo.rollback(:comment_not_created)
      end
    end)
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
           {:ok, _}        <- increment_reactions_count(story)
      do
        reaction
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Remove the comment from the story.
  """
  def remove_comment(%Comment{} = comment),
    # We don't decrement story comments counter, because this comment
    # still displayed, but as deleted.
    do: Stores.Comment.delete(comment)

  @doc """
  Remove the user's reaction from the story.
  """
  def remove_reaction(%User{} = user, %Story{} = story),
    do: remove_reaction(story, user)
  def remove_reaction(%Story{} = story, %User{} = user) do
    Repo.transaction(fn ->
      with {:ok, reaction} <- Stores.Reaction.get_valid_by_user_and_object(
                                user, 
                                story
                              ),
           {:ok, reaction} <- Stores.Reaction.delete(reaction),
           {:ok, _}        <- decrement_reactions_count(story)
      do
        reaction
      else
        _ -> Repo.rollback(:reaction_not_deleted)
      end
    end)
  end

  @doc """
  Increment comments count of the story.
  """
  def increment_comments_count(%Story{} = story),
    do: update(story, %{comments_count: story.comments_count + 1})

  @doc """
  Increment reactions count of the story.
  """
  def increment_reactions_count(%Story{} = story),
    do: update(story, %{reactions_count: story.reactions_count + 1})

  @doc """
  Decrement comments count of the story.
  """
  def decrement_comments_count(%Story{} = story),
    do: update(story, %{comments_count: story.comments_count - 1})

  @doc """
  Decrement reactions count of the story.
  """
  def decrement_reactions_count(%Story{} = story),
    do: update(story, %{reactions_count: story.reactions_count - 1})

  @doc """
  Delete the story.
  """
  def delete(%Story{} = story),
    # We don't decrement user's stories counter, because this story
    # still displayed in the user's history of stories.
    do: update(story, %{is_removed: true})


  defp changeset(%Story{} = story),
    do: changeset(story, %{})
  defp changeset(%Ecto.Changeset{} = changeset),
    do: changeset(changeset, %{})

  defp changeset(%Story{} = story, attrs) do
    story
    |> change()
    |> changeset(attrs)
  end

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    %{changeset | errors: [], valid?: true}
    |> cast(attrs, [
      :author_id,
      :topic_id,
      :content,
      :comments_count,
      :reactions_count,
      :is_published,
      :is_removed,
      :published_at
    ])
    |> validate_required([
      :id,
      :author_id,
      :content,
      :comments_count,
      :reactions_count,
      :is_published,
      :is_removed,
      :submitted_at
    ])
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
    |> validate_number(:reactions_count, greater_than_or_equal_to: 0)
    |> put_published_datetime()
    |> put_edited_datetime()
  end

  defp put_published_datetime(changeset) do
    case changeset do
      # TODO: pass, if published date was set manually
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
          nil -> changeset  # it's a new story
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
