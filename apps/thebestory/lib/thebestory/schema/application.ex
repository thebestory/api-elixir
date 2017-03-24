defmodule TheBestory.Schema.Application do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Authorization
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "applications" do
    field :name, :string
    field :secret, :string
    field :redirect_uri, :string
    field :settings, :map

    belongs_to :user, User
    has_many :authorizations, Authorization

    has_many :posts, Post

    timestamps()
  end

  @doc """
  Returns the list of applications.

  ## Examples

      iex> list()
      [%Application{}, ...]

  """
  def list do
    Repo.all(Application)
  end

  @doc """
  Gets a single application.

  Raises `Ecto.NoResultsError` if the Application does not exist.

  ## Examples

      iex> get!(123)
      %Application{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Application, id)

  @doc """
  Creates a application.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Application{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Application{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a application.

  ## Examples

      iex> update(application, %{field: new_value})
      {:ok, %Application{}}

      iex> update(application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Application{} = application, attrs) do
    application
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application.

  ## Examples

      iex> delete(application)
      {:ok, %Application{}}

      iex> delete(application)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Application{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application changes.

  ## Examples

      iex> change(application)
      %Ecto.Changeset{source: %Application{}}

  """
  def change(%Application{} = application) do
    changeset(application, %{})
  end

  defp changeset(%Application{} = application, attrs) do
    application
    |> cast(params, [:name, :redirect_uri, :settings, :user_id])
    |> validate_required([:name, :redirect_uri, :user_id])
    |> validate_length(:name, min: 3, max: 64)
    |> validate_format(:name, ~r/\A([a-zA-Z]+)([0-9a-zA-Z]*)\z/i)
    |> unique_constraint(:name)
    |> put_secret
  end

  defp put_secret(changeset) do
    put_change(changeset, :secret, generate_secret)
  end

  def generate_secret, 
    do: SecureRandom.urlsafe_base64 # TODO: Change a length of secret
end
