defmodule TheBestory.Schema.Story do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.Topic
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "stories" do
    field :content, :string
    
    field :is_published, :boolean, default: false
    field :is_removed, :boolean, default: false

    field :reactions_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    field :published_at, :utc_datetime
    field :edited_at, :utc_datetime

    belongs_to :author, User, type: :string
    belongs_to :topic, Topic, type: :string

    timestamps()
  end

  @doc """
  Returns the list of stories.
  """
  defp list do
    Repo.all(Story)
  end

  @doc """
  Gets a single story.
  """
  def get(id), do: Repo.get(Story, id)
  def get!(id), do: Repo.get!(Story, id)

  @doc """
  Creates a story.
  """
  def create(%User{} = author, %Topic{} = topic, attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Story{}
      |> Repo.preload([:author, :topic])
      |> put_assoc(:author, author)
      |> put_assoc(:topic, topic)
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a story.
  """
  def update(%Story{} = story, %User{} = author, %Topic{} = topic, 
             attrs \\ %{}) do
    story
    |> Repo.preload([:author, :topic])
    |> put_assoc(:author, author)
    |> put_assoc(:topic, topic)
    |> update(attrs)
  end
  def update(%Story{} = story, %User{} = author, attrs \\ %{}) do
    story
    |> Repo.preload([:author])
    |> put_assoc(:author, author)
    |> update(attrs)
  end
  def update(%Story{} = story, %Topic{} = topic, attrs \\ %{}) do
    story
    |> Repo.preload([:topic])
    |> put_assoc(:topic, topic)
    |> update(attrs)
  end
  def update(%Story{} = story, attrs \\ %{}) do
    story
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a story.
  """
  defp delete(%Story{} = story) do
    Repo.delete(story)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking story changes.
  """
  def change(%Story{} = story) do
    changeset(story, %{})
  end

  defp changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:content, :is_published, :is_removed])
    |> validate_required([:content, :is_published, :is_removed])
    |> cast_assoc(:author, [:required])
    |> cast_assoc(:topic, [:required])
  end
end
