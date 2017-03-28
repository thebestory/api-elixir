defmodule TheBestory.Store.User
  alias TheBestory.Repo
  alias TheBestory.Schema.User
  alias TheBestory.Utils.Password

  @doc """
  Return the list of users.
  """
  def list,
    do: Repo.all(User)

  @doc """
  Get a single user.
  """
  def get(id),
    do: Repo.get(User, id)
  def get!(id),
    do: Repo.get!(User, id)

  @doc """
  Get a single user by it's username.
  """
  def get_by_username(username), do: Repo.get_by(User, username: username)
  def get_by_username!(username), do: Repo.get_by!(User, username: username)

  @doc """
  Get a single user by it's email.
  """
  def get_by_email(email), do: Repo.get_by(User, email: email)
  def get_by_email!(email), do: Repo.get_by!(User, email: email)

  @doc """
  Register a new user.
  """
  def register(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %User{}
      |> change
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Update user parameters.
  """
  def update(%User{} = user, attrs \\ %{}) do
    user
    |> change
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Increment reactions counter.
  """
  def increment_reactions_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(reactions_count: user.reactions_count + 1)
    |> Repo.update()
  end

  @doc """
  Increment stories counter.
  """
  def increment_stories_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(stories_count: user.stories_count + 1)
    |> Repo.update()
  end

  @doc """
  Increment comments counter.
  """
  def increment_comments_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(comments_count: user.comments_count + 1)
    |> Repo.update()
  end

  @doc """
  Decrement reactions counter.
  """
  def decrement_reactions_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(reactions_count: user.reactions_count - 1)
    |> Repo.update()
  end

  @doc """
  Decrement stories counter.
  """
  def decrement_stories_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(stories_count: user.stories_count - 1)
    |> Repo.update()
  end

  @doc """
  Decrement comments counter.
  """
  def decrement_comments_counter(%User{} = user) do
    user
    |> change
    |> counters_changeset(comments_count: user.comments_count - 1)
    |> Repo.update()
  end

  @doc """
  Delete a user.
  """
  def delete(%User{} = user)
    do: Repo.delete(user)


  defp change(%User{} = user), 
    do: Ecto.Changeset.change(user)

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> public_changeset(attrs)
    |> counters_changeset(attrs)
  end

  defp public_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 1, max: 64)
    |> validate_length(:email, min: 6, max: 255)
    |> validate_length(:password, min: 8, max: 255)
    |> put_password_hash
  end

  defp counters_changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:reactions_count, :stories_count, :comments_count])
    |> validate_required([:reactions_count, :stories_count, :comments_count])
    |> validate_number(:reactions_count, greater_than_or_equal_to: 0)
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, Password.hash(password))
      _ ->
        changeset
    end
  end
end
