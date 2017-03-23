defmodule TheBestory.Schema.User do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias Comeonin.Bcrypt
  alias TheBestory.Repo
  alias TheBestory.Schema.Application
  alias TheBestory.Schema.Token
  alias TheBestory.Schema.Authorization
  alias TheBestory.Schema.Post

  @primary_key {:id, :string, []}

  schema "users" do
    field :email, :string
    field :password, :string
    field :settings, :map

    has_many :apps, Application
    has_many :tokens, Token
    has_many :authorizations, Authorization

    has_many :posts, Post

    timestamps()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list()
      [%User{}, ...]

  """
  def list do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get!(123)
      %User{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create(%{field: value})
      {:ok, %User{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

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

  ## Examples

      iex> update(user, %{field: new_value})
      {:ok, %User{}}

      iex> update(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete(user)
      {:ok, %User{}}

      iex> delete(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%User{} = user) do
    Repo.delete(user)
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
    |> cast(attrs, [:email, :password, :settings])
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 6, max: 255)
  end

  def settings_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:settings])
    |> validate_required([:settings])
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 8, max: 255)
    |> put_password_hash
  end

  def password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
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
    do: Bcrypt.checkpw(password, crypted_password)

  def salt_password(password), 
    do: Bcrypt.hashpwsalt(password)

  def generate_token, 
    do: SecureRandom.urlsafe_base64
end
