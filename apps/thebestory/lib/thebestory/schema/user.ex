defmodule TheBestory.Schema.User do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  # alias Comeonin.Bcrypt
  alias TheBestory.Repo
  alias TheBestory.Schema.Post
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string

    has_many :posts, Post

    timestamps()
  end

  @doc """
  Gets a single user.
  """
  def get(id), do: Repo.get(User, id)
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Registers a user.
  """
  def register(attrs \\ %{}) do
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
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change(%User{} = user) do
    changeset(user, %{})
  end

  defp changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 1, max: 64)
    |> validate_length(:email, min: 6, max: 255)
    |> validate_length(:password, min: 8, max: 255)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password, salt_password(password))
      _ ->
        changeset
    end
  end

  def match_password(password, crypted_password),
    # do: Bcrypt.checkpw(password, crypted_password)
    do: password == crypted_password

  def salt_password(password), 
    # do: Bcrypt.hashpwsalt(password)
    do: password
end
