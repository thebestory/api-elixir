defmodule TheBestory.Store.Topic do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Topic

  @doc """
  Return the list of topics.
  """
  def list,
    do: Repo.all(Topic)

  @doc """
  Get a single topic.
  """
  def get(id),
    do: Repo.get(Topic, id)
  def get!(id),
    do: Repo.get!(Topic, id)

  @doc """
  Get a single topic by it's slug.
  """
  def get_by_slug(slug),
    do: Repo.get_by(Topic, slug: slug)
  def get_by_slug!(slug),
    do: Repo.get_by!(Topic, slug: slug)

  @doc """
  Create a topic.
  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Topic{}
      |> change
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Update a topic.
  """
  def update(%Topic{} = topic, attrs \\ %{}) do
    topic
    |> change
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Increment stories count.
  """
  def increment_stories_count(%Topic{} = topic) do
    topic
    |> change
    |> counters_changeset(%{stories_count: topic.stories_count + 1})
    |> Repo.update()
  end

  @doc """
  Decrement stories count.
  """
  def decrement_stories_count(%Topic{} = topic) do
    topic
    |> change
    |> counters_changeset(%{stories_count: topic.stories_count - 1})
    |> Repo.update()
  end

  @doc """
  Delete a topic.
  """
  def delete(%Topic{} = topic),
    do: Repo.delete(topic)


  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> public_changeset(attrs)
    |> counters_changeset(attrs)
  end

  defp public_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:title, :slug, :description, :icon, :is_active])
    |> validate_required([:title, :slug, :is_active])
  end

  defp counters_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:stories_count])
    |> validate_required([:stories_count])
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
  end
end
