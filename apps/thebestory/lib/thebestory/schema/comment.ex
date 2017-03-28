defmodule TheBestory.Schema.Comment do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Comment
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "comments" do
    field :content, :string
    
    field :reactions_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false

    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime

    belongs_to :author, User, type: :string
    belongs_to :story, Story, type: :string
    belongs_to :parent, Comment, type: :string

    timestamps()
  end

  @doc """
  Returns the list of comments.
  """
  defp list do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.
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
    Enum.reduce([:author, :story, :parent], comment, fn(ref) ->
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
  Deletes a comment.
  """
  defp delete(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.
  """
  def change(%Comment{} = comment) do
    changeset(comment, %{})
  end

  defp changeset(%Comment{} = comment, attrs) do
    comment
    |> Repo.preload([:author, :story, :parent])
    |> cast(attrs, [:content, :reactions_count, :comments_count, :is_published, 
                    :is_removed, :published_at, :edited_at])
    |> validate_required([:content, :reactions_count, :comments_count, 
                          :is_published, :is_removed])
    |> cast_assoc(:author, [:required])
    |> cast_assoc(:topic, [:required])
    |> cast_assoc(:parent)
    |> validate_number(:reactions_count, greater_than_or_equal_to: 0)
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
  end
end
