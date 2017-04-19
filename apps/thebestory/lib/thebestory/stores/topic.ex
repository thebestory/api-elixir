defmodule TheBestory.Stores.Topic do
  import Ecto.Changeset, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Topic
  alias TheBestory.Stores

  @id_type "topic"

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
    Repo.transaction(fn ->
      with {:ok, id}    <- Stores.ID.generate(@id_type),
           {:ok, topic} <- %Topic{}
                           |> changeset(%{
                             stories_count: 0
                           })
                           |> changeset(attrs)
                           |> put_change(:id, id)
                           |> changeset()
                           |> Repo.insert()
      do
        topic
      else
        _ -> Repo.rollback(:topic_not_created)
      end
    end)
  end

  @doc """
  Update the topic.
  """
  def update(%Topic{} = topic, attrs \\ %{}) do
    topic
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Increment stories count of the topic.
  """
  def increment_stories_count(%Topic{} = topic),
    do: update(topic, %{stories_count: topic.stories_count + 1})

  @doc """
  Decrement stories count of the topic.
  """
  def decrement_stories_count(%Topic{} = topic),
    do: update(topic, %{stories_count: topic.stories_count - 1})

  @doc """
  Delete the topic.
  """
  def delete(%Topic{} = topic),
    do: update(topic, %{is_active: false})


  defp changeset(%Topic{} = topic),
    do: changeset(topic, %{})
  defp changeset(%Ecto.Changeset{} = changeset),
    do: changeset(changeset, %{})

  defp changeset(%Topic{} = topic, attrs) do
    topic
    |> change()
    |> changeset(attrs)
  end

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    %{changeset | errors: [], valid?: true}
    |> cast(attrs, [
      :title,
      :slug,
      :description,
      :icon,
      :stories_count,
      :is_active
    ])
    |> validate_required([
      :id,
      :title,
      :slug,
      :stories_count,
      :is_active
    ])
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
  end
end
