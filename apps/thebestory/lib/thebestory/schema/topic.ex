defmodule TheBestory.Schema.Topic do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Post
  alias TheBestory.Schema.Topic

  @primary_key {:id, :string, []}

  schema "topics" do
    field :description, :string, default: ""
    field :icon, :string, default: ""
    field :is_active, :boolean, default: false
    field :slug, :string
    field :posts_count, :integer, default: 0
    field :title, :string

    has_many :posts, Post

    timestamps()
  end

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list()
      [%Topic{}, ...]

  """
  def list do
    Repo.all(Topic)
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get!(123)
      %Topic{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Topic, id)

  @doc """
  Creates a topic.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Topic{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Topic{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Topic{} = topic, attrs) do
    topic
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete(topic)
      {:ok, %Topic{}}

      iex> delete(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change(topic)
      %Ecto.Changeset{source: %Topic{}}

  """
  def change(%Topic{} = topic) do
    changeset(topic, %{})
  end

  defp changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:slug, :title, :description, :icon, :is_active])
    |> validate_required([:slug, :title, :is_active])
  end
end
