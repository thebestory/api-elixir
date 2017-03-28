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
      |> Ecto.Changeset.put_change(:id, Integer.to_string(id))
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
          true -> comment |> put_assoc(ref, Map.get(attrs, ref))
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
      with {:ok, reaction} <- Store.Reaction.create(
              object_type: @reaction_object_type,
              object_id: comment.id,
              user: user
            ),
           {:ok, _} <- increment_reactions_counter(comment) do
        {:ok, reaction}
      else
        _ -> {:error, :something_wrong}
      end
    end)
  end

  @doc """
  Increment reactions counter.
  """
  def increment_reactions_counter(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(reactions_count: comment.reactions_count + 1)
    |> Repo.update()
  end

  @doc """
  Increment comments counter.
  """
  def increment_comments_counter(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(comments_count: comment.comments_count + 1)
    |> Repo.update()
  end

  @doc """
  Decrement reactions counter.
  """
  def decrement_reactions_counter(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(reactions_count: comment.reactions_count - 1)
    |> Repo.update()
  end

  @doc """
  Decrement comments counter.
  """
  def decrement_comments_counter(%Comment{} = comment) do
    comment
    |> change
    |> counters_changeset(comments_count: comment.comments_count - 1)
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
  end

  defp public_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end

  defp create_changeset(%Ecto.Changeset{} = changeset, _attrs) do
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
