defmodule TheBestory.Schema.User do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Story
  alias TheBestory.Schema.User
  alias TheBestory.Utils.Password

  @primary_key {:id, :string, []}

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string

    field :stories_count, :integer, default: 0
    field :comments_count, :integer, default: 0

    has_many :stories, Story

    timestamps()
  end

  @doc """
  Returns the list of users.
  """
  defp list do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  """
  def get(id), do: Repo.get(User, id)
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by it's username.
  """
  def get_by_username(username), do: Repo.get_by(User, username: username)
  def get_by_username!(username), do: Repo.get_by!(User, username: username)

  @doc """
  Gets a single user by it's email.
  """
  def get_by_email(email), do: Repo.get_by(User, email: email)
  def get_by_email!(email), do: Repo.get_by!(User, email: email)

  @doc """
  Creates a user.
  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %User{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a user.
  """
  def update(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  defp delete(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change(%User{} = user) do
    changeset(user, %{})
  end

  defp changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :stories_count, 
                    :comments_count])
    |> validate_required([:username, :email, :password, :stories_count, 
                          :comments_count])
    |> validate_length(:username, min: 1, max: 64)
    |> validate_length(:email, min: 6, max: 255)
    |> validate_length(:password, min: 8, max: 255)
    |> validate_number(:stories_count, greater_than_or_equal_to: 0)
    |> validate_number(:comments_count, greater_than_or_equal_to: 0)
    |> put_password_hash
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
