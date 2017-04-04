defmodule TheBestory.Stores.Comment do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.ID
  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.User
  alias TheBestory.Stores

  @id_type "comment"

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
  def create(%{author: %User{} = author, 
               root: %{id: root_id} = _root,
               parent: %{id: parent_id} = _parent} = attrs) do
    Repo.transaction(fn ->
      with {:ok, id} <- Stores.ID.generate(@id_type) do
        with {:ok, comment} <- %Comment{}
                               |> Repo.preload([:author])
                               |> change
                               |> put_assoc(:author, author)
                               |> put_change(:root_id, root_id)
                               |> put_change(:parent_id, parent_id)
                               |> changeset(attrs)
                               |> put_change(:id, id)
                               |> Repo.insert(),
             {:ok, _} <- Stores.User.increment_comments_count(author)
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
    refs = [:author]

    Enum.reduce(
      refs,
      comment
      |> Repo.preload(refs)
      |> change,
      fn(ref, comment) ->
        # TODO: what we should to do with counters ???
        case Map.has_key?(attrs, ref) do
          true -> comment |> put_assoc(ref, Map.get(attrs, ref))
             _ -> comment
        end
      end
    )
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
      with {:ok, reaction} <- Stores.Reaction.create(%{
                                user: user,
                                object: comment
                              }),
           {:ok, _} <- increment_reactions_count(comment)
      do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Add a comment to the comment.
  """
  def add_comment(%{author: %User{} = _author, 
                    comment: %Comment{} = comment} = attrs) do
    attrs = attrs
            |> Map.put(:root, %ID{id: comment.root_id})
            |> Map.put(:parent, comment)

    Repo.transaction(fn ->
      with {:ok, comment} <- create(attrs),
           {:ok, _} <- increment_comments_count(comment)
      do
        {:ok, comment}
      else
        _ -> Repo.rollback(:comment_not_created)
      end
    end)
  end

  @doc """
  Remove a user's reaction from the comment.
  """
  def remove_reaction(%User{} = user, %Comment{} = comment),
    do: remove_reaction(comment, user)
  def remove_reaction(%Comment{} = comment, %User{} = user) do
    # XXX: What if there is two+ (wtf) or zero valid reactions for user+object?
    with {:ok, reaction} <- Stores.Reaction.get_valid_by_user_and_object(user, comment) do
      Repo.transaction(fn ->
        with {:ok, reaction} <- Stores.Reaction.invalidate(reaction),
             {:ok, _} <- decrement_reactions_count(comment)
        do
          {:ok, reaction}
        else
          _ -> Repo.rollback(:reaction_not_invalidated)
        end
      end)
    end
  end

  @doc """
  Remove a comment from the comment.
  """
  def remove_comment(%Comment{} = comment),
    do: delete(comment)

  @doc """
  Increment reactions count.
  """
  def increment_reactions_count(%Comment{} = comment) do
    comment
    |> change
    |> changeset(%{reactions_count: comment.reactions_count + 1})
    |> Repo.update()
  end

  @doc """
  Increment comments count.
  """
  def increment_comments_count(%Comment{} = comment) do
    comment
    |> change
    |> changeset(%{comments_count: comment.comments_count + 1})
    |> Repo.update()
  end

  @doc """
  Decrement reactions count.
  """
  def decrement_reactions_count(%Comment{} = comment) do
    comment
    |> change
    |> changeset(%{reactions_count: comment.reactions_count - 1})
    |> Repo.update()
  end

  @doc """
  Decrement comments count.
  """
  def decrement_comments_count(%Comment{} = comment) do
    comment
    |> change
    |> changeset(%{comments_count: comment.comments_count - 1})
    |> Repo.update()
  end

  @doc """
  Delete a comment.
  """
  def delete(%Comment{} = comment) do
    # We don't decrement user's comments counter, because this comment still
    # displayed in the comments tree, and user's history of comments
    # (but, as removed comment, without ability to show content)
    comment
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
    |> validate_required([:author, :root_id, :parent_id])
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
      %Ecto.Changeset{valid?: true, data: comment, changes: %{content: _}} ->
        case comment.id do
          nil -> changeset # it's a new comment
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
