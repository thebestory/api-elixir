defmodule TheBestory.Schema.Post do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Post
  alias TheBestory.Schema.Topic

  @primary_key {:id, :string, []}

  schema "posts" do
    field :content, :string
    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false
    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime
    field :reactions_count, :integer, default: 0
    field :replies_count, :integer, default: 0

    belongs_to :topic, Topic, type: :string

    timestamps()
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list()
      [%Post{}, ...]

  """
  def list do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get!(123)
      %Post{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Post, id)
  def get!(id, :preload), do: Repo.get!(Post |> preload(:topic), id)

  @doc """
  Creates a post.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Post{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Post{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Post{} = post, attrs) do
    post
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete(post)
      {:ok, %Post{}}

      iex> delete(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change(%Post{} = post) do
    changeset(post, %{})
  end

  defp changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:content, :is_published, :is_removed, :topic_id])
    |> validate_required([:content, :is_published, :is_removed, :topic_id])
  end
end
