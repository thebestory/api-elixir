defmodule TheBestory.Stores.Comment do
  import Ecto.Changeset, warn: false

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
               root: %{id: _} = root,
               parent: %{id: _} = parent} = attrs) do
    Repo.transaction(fn ->
      with {:ok, id}      <- Stores.ID.generate(@id_type),
           {:ok, comment} <- %Comment{}
                             |> changeset(%{
                               comments_count: 0,
                               reactions_count: 0,
                               is_published: false,
                               is_removed: false
                             })
                             |> changeset(attrs)
                             |> changeset(%{
                               author_id: author.id
                             })
                             |> put_change(:id, id)
                             |> put_change(:root_id, root.id)
                             |> put_change(:parent_id, parent.id)
                             |> put_change(:submitted_at, DateTime.utc_now())
                             |> changeset()
                             |> Repo.insert(),
           {:ok, _}       <- Stores.User.increment_comments_count(author),
           {:ok, _}       <- increment_parent_comments_count(parent)
      do
        {:ok, comment}
      else
        _ -> Repo.rollback(:comment_not_created)
      end
    end)
  end

  defp increment_parent_comments_count(%Comment{} = parent),
    do: increment_comments_count(parent)
  defp increment_parent_comments_count(_parent),
    do: {:ok, :not_a_comment}

  @doc """
  Update the comment.
  """
  def update(%Comment{} = comment, attrs \\ %{}) do
    Repo.transaction(fn ->
      chngst = changeset(comment, attrs)

      if Map.has_key?(attrs, :author) and 
         comment.author_id != Map.get(attrs, :author).id
      do
        with {:ok, old} <- Stores.User.get(comment.author_id),
             {:ok, new} <- Stores.User.get(Map.get(attrs, :author).id),
             {:ok, _}   <- Stores.User.decrement_comments_count(old),
             {:ok, _}   <- Stores.User.increment_comments_count(new)
        do
          chngst = changeset(chngst, %{author_id: new.id})
          Repo.update(chngst)
        else
          _ -> Repo.rollback(:comment_not_updated)
        end
      else
        Repo.update(chngst)
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
           {:ok, _}       <- increment_comments_count(comment)
      do
        {:ok, comment}
      else
        _ -> Repo.rollback(:comment_not_created)
      end
    end)
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
           {:ok, _}        <- increment_reactions_count(comment)
      do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Remove the comment from the comment.
  """
  def remove_comment(%Comment{} = comment),
    # We don't decrement comment comments counter, because this comment
    # still displayed, but as deleted.
    do: delete(comment)

  @doc """
  Remove the user's reaction from the comment.
  """
  def remove_reaction(%User{} = user, %Comment{} = comment),
    do: remove_reaction(comment, user)
  def remove_reaction(%Comment{} = comment, %User{} = user) do
    Repo.transaction(fn ->
      with {:ok, reaction} <- Stores.Reaction.get_valid_by_user_and_object(
                                user, 
                                comment
                              ),
           {:ok, reaction} <- Stores.Reaction.delete(reaction),
           {:ok, _}        <- decrement_reactions_count(comment)
      do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_deleted)
      end
    end)
  end

  @doc """
  Increment comments count of the comment.
  """
  def increment_comments_count(%Comment{} = comment),
    do: update(comment, %{comments_count: comment.comments_count + 1})

  @doc """
  Increment reactions count of the comment.
  """
  def increment_reactions_count(%Comment{} = comment),
    do: update(comment, %{reactions_count: comment.reactions_count + 1})

  @doc """
  Decrement comments count of the comment.
  """
  def decrement_comments_count(%Comment{} = comment),
    do: update(comment, %{comments_count: comment.comments_count - 1})

  @doc """
  Decrement reactions count of the comment.
  """
  def decrement_reactions_count(%Comment{} = comment),
    do: update(comment, %{reactions_count: comment.reactions_count - 1})

  @doc """
  Delete the comment.
  """
  def delete(%Comment{} = comment),
    # We don't decrement user's comments counter, because this comment
    # still displayed in the comments tree, and user's history of
    # comments (but, as deleted).
    do: update(comment, %{is_removed: true})


  defp changeset(%Comment{} = comment),
    do: changeset(comment, %{})
  defp changeset(%Ecto.Changeset{} = changeset),
    do: changeset(changeset, %{})

  defp changeset(%Comment{} = comment, attrs) do
    comment
    |> change()
    |> changeset(attrs)
  end

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    %{changeset | errors: [], valid?: true}
    |> cast(attrs, [
      :author_id,
      :content,
      :comments_count,
      :reactions_count,
      :is_published,
      :is_removed,
      :published_at
    ])
    |> validate_required([
      :author_id,
      :root_id,
      :parent_id,
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
      %Ecto.Changeset{valid?: true, data: comment, changes: %{content: _}} ->
        case comment.id do
          nil -> changeset # it's a new comment
            _ -> put_change(changeset, :edited_at, DateTime.utc_now())
        end
      _ -> changeset
    end
  end
end
