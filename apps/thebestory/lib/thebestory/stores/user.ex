defmodule TheBestory.Stores.User do
  import Ecto.Changeset, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.User
  alias TheBestory.Stores
  alias TheBestory.Utils.Password

  @id_type "user"

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
  def get_by_username(username),
    do: Repo.get_by(User, username: username)
  def get_by_username!(username),
    do: Repo.get_by!(User, username: username)

  @doc """
  Get a single user by it's email.
  """
  def get_by_email(email),
    do: Repo.get_by(User, email: email)
  def get_by_email!(email),
    do: Repo.get_by!(User, email: email)

  @doc """
  Create a user.
  """
  def create(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, id}   <- Stores.ID.generate(@id_type),
           {:ok, user} <- %User{}
                          |> changeset(%{
                            comments_count: 0,
                            reactions_count: 0,
                            stories_count: 0
                          })
                          |> changeset(attrs)
                          |> put_change(:id, id)
                          |> put_change(:registered_at, DateTime.utc_now())
                          |> changeset()
                          |> Repo.insert()
      do
        {:ok, user}
      else
        _ -> Repo.rollback(:user_not_created)
      end
    end)
  end

  @doc """
  Update the user.
  """
  def update(%User{} = user, attrs \\ %{}) do
    user
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Increment comments count of the user.
  """
  def increment_comments_count(%User{} = user),
    do: update(user, %{comments_count: user.comments_count + 1})

  @doc """
  Increment reactions count of the user.
  """
  def increment_reactions_count(%User{} = user),
    do: update(user, %{reactions_count: user.reactions_count + 1})

  @doc """
  Increment stories count of the user.
  """
  def increment_stories_count(%User{} = user),
    do: update(user, %{stories_count: user.stories_count + 1})

  @doc """
  Decrement comments count of the user.
  """
  def decrement_comments_count(%User{} = user),
    do: update(user, %{comments_count: user.comments_count - 1})

  @doc """
  Decrement reactions count of the user.
  """
  def decrement_reactions_count(%User{} = user),
    do: update(user, %{reactions_count: user.reactions_count - 1})

  @doc """
  Decrement stories count of the user.
  """
  def decrement_stories_count(%User{} = user),
    do: update(user, %{stories_count: user.stories_count - 1})


  defp changeset(%User{} = user),
    do: changeset(user, %{})
  defp changeset(%Ecto.Changeset{} = changeset),
    do: changeset(changeset, %{})

  defp changeset(%User{} = user, attrs) do
    user
    |> change()
    |> changeset(attrs)
  end

  defp changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [
      :username,
      :email,
      :password,
      :comments_count,
      :reactions_count,
      :stories_count
    ])
    |> validate_required([
      :id,
      :username,
      :email,
      :password,
      :comments_count,
      :reactions_count,
      :stories_count,
      :registered_at
    ])
    |> validate_length(:username, min: 2, max: 64)
    |> validate_length(:email, min: 6, max: 255)
    |> validate_length(:password, min: 8, max: 255)
    |> validate_format(:email, ~r/@/)
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
    |> validate_number(:reactions_count, greater_than_or_equal_to: 0)
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
    |> put_password_hash()
  end

  # TODO: Is it safe to save password change in the real field?
  # What, if some errors will be raised at hashing? Will the password be 
  # commited to DB?
  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, Password.hash(password))
      _ ->
        changeset
    end
  end
end
