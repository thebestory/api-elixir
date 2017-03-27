defmodule TheBestory.Schema.Topic do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.Topic

  @primary_key {:id, :string, []}

  schema "topics" do
    field :title, :string
    field :slug, :string
    field :description, :string, default: ""
    field :icon, :string, default: ""

    field :stories_count, :integer, default: 0

    field :is_active, :boolean, default: false

    has_many :stories, Story

    timestamps()
  end

  @doc """
  Returns the list of topics.
  """
  def list do
    Repo.all(Topic)
  end

  @doc """
  Gets a single topic.
  """
  def get(id), do: Repo.get(Topic, id)
  def get!(id), do: Repo.get!(Topic, id)

  @doc """
  Creates a topic.
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
  """
  def update(%Topic{} = topic, attrs) do
    topic
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.
  """
  defp delete(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.
  """
  def change(%Topic{} = topic) do
    changeset(topic, %{})
  end

  defp changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:title, :slug, :description, :icon, :stories_count, 
                    :is_active])
    |> validate_required([:title, :slug, :stories_count, :is_active])
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
  end
end
