defmodule TheBestory.Schema.Token do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.User

  @expires_in Application.get_env(:authable, :expires_in)

  @primary_key {:id, :string, []}

  schema "tokens" do
    field :name, :string
    field :value, :string
    field :expires_at, :integer
    field :details, :map

    belongs_to :user, User

    timestamps()
  end

  @doc """
  Returns the list of tokens.

  ## Examples

      iex> list()
      [%Token{}, ...]

  """
  def list do
    Repo.all(Token)
  end

  @doc """
  Gets a single token.

  Raises `Ecto.NoResultsError` if the Token does not exist.

  ## Examples

      iex> get!(123)
      %Token{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Token, id)

  @doc """
  Creates a token.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Token{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Token{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Token{} = token, attrs) do
    token
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete(token)
      {:ok, %Token{}}

      iex> delete(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Token{} = token) do
    Repo.delete(token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token changes.

  ## Examples

      iex> change(token)
      %Ecto.Changeset{source: %Token{}}

  """
  def change(%Token{} = token) do
    changeset(token, %{})
  end

  defp changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:name, :expires_at, :details, :user_id])
    |> validate_required([:name, :expires_at, :user_id])
    |> put_token_value
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  def authorization_code_changeset(%Token{} = token, attrs \\ :empty) do
    token
    |> changeset(attrs)
    |> put_token_name("authorization_code")
    |> put_expires_at(:os.system_time(:seconds) + @expires_in[:authorization_code])
  end

  def refresh_token_changeset(%Token{} = token, attrs \\ :empty) do
    token
    |> changeset(attrs)
    |> put_token_name("refresh_token")
    |> put_expires_at(:os.system_time(:seconds) + @expires_in[:refresh_token])
  end

  def access_token_changeset(%Token{} = token, attrs \\ :empty) do
    token
    |> changeset(attrs)
    |> put_token_name("access_token")
    |> put_expires_at(:os.system_time(:seconds) + @expires_in[:access_token])
  end

  def session_token_changeset(%Token{} = token, attrs \\ :empty) do
    token
    |> changeset(attrs)
    |> put_token_name("session_token")
    |> put_app_scopes
    |> put_expires_at(:os.system_time(:seconds) + @expires_in[:session_token])
  end

  def is_expired?(token) do
    token.expires_at < :os.system_time(:seconds)
  end

  defp put_token_name(changeset, name) do
    put_change(changeset, :name, name)
  end

  defp put_token_value(changeset) do
    put_change(changeset, :value, generate_token)
  end

  defp put_expires_at(changeset, expires_at) do
    put_change(changeset, :expires_at, expires_at)
  end

  defp put_app_scopes(changeset) do
    scopes = Enum.join(Application.get_env(:authable, :scopes), ",")
    put_change(changeset, :details, %{scope: scopes})
  end

  def generate_token, 
    do: SecureRandom.urlsafe_base64  # TODO: Change a length of token
end
