defmodule TheBestory.Store.Comment do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User
  alias TheBestory.Store

  @reaction_object_type "comment"

  @doc """
  Return the list of comments.
  """
  def list, 
    do: Repo.all(Comment)

  @doc """
  Get a single comment.
  """
  def get(id),
    do: Repo.get(Comment, id)
  def get!(id),
    do: Repo.get!(Comment, id)

  @doc """
  Create a comment.
  """
  def create(%{author: %User{} = author, story: %Story{} = story} = attrs) do
    Repo.transaction(fn ->
      with {:ok, id} <- Snowflake.next_id() do
        with {:ok, comment} <- %Comment{}
                               |> Repo.preload([:author, :story])
                               |> change
                               |> put_assoc(:author, author)
                               |> put_assoc(:story, story)
                               |> changeset(attrs)
                               |> put_change(:id, Integer.to_string(id))
                               |> Repo.insert(),
             {:ok, _} <- Store.User.increment_comments_count(author),
             {:ok, _} <- Store.Story.increment_comments_count(story)
        do
          {:ok, comment}
        else
          _ -> Repo.rollback(:comment_not_created)
        end
      else
        _ -> Repo.rollback(:id_not_generated)
      end
    end)
  end

  @doc """
  Update a comment.
  """
  def update(%Comment{} = comment, attrs \\ %{}) do
    refs = [:author, :story, :parent]

    Enum.reduce(
      refs,
      comment
      |> Repo.preload(refs)
      |> change,
      fn(ref, comment) ->
        case Map.has_key?(attrs, ref) do
          true -> comment |> put_assoc(ref, Map.get(attrs, ref)) # TODO: increment/decrement values for old/new ref
             _ -> comment
        end
      end)
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Add a user's reaction to the comment.
  """
  def add_reaction(%User{} = user, %Comment{} = comment),
    do: add_reaction(comment, user)
  def add_reaction(%Comment{} = comment, %User{} = user) do
    Repo.transaction(fn ->
      with {:ok, reaction} <- Store.Reaction.create(%{
                                object_type: @reaction_object_type,
                                object_id: comment.id,
                                user: user
                              }),
           {:ok, _} <- increment_reactions_count(comment) do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Increment reactions count.
  """
  def increment_reactions_count(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(%{reactions_count: comment.reactions_count + 1})
    |> Repo.update()
  end

  @doc """
  Increment comments count.
  """
  def increment_comments_count(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(%{comments_count: comment.comments_count + 1})
    |> Repo.update()
  end

  @doc """
  Decrement reactions count.
  """
  def decrement_reactions_count(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(%{reactions_count: comment.reactions_count - 1})
    |> Repo.update()
  end

  @doc """
  Decrement comments count.
  """
  def decrement_comments_count(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(%{comments_count: comment.comments_count - 1})
    |> Repo.update()
  end

  @doc """
  Delete a comment.
  """
  def delete(%Comment{} = comment),
    do: Repo.delete(comment)


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
    |> validate_required([:author, :story])
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
          nil -> changeset # it's a new story
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
