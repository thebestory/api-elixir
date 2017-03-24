defmodule TheBestory.Schema.Authorization do
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Application
  alias TheBestory.Schema.User

  @primary_key {:id, :string, []}

  schema "authorizations" do
    field :scope, :string

    belongs_to :application, Application
    belongs_to :user, User

    timestamps()
  end

  @doc """
  Returns the list of authorizations.

  ## Examples

      iex> list()
      [%Authorization{}, ...]

  """
  def list do
    Repo.all(Authorization)
  end

  @doc """
  Gets a single authorization.

  Raises `Ecto.NoResultsError` if the Authorization does not exist.

  ## Examples

      iex> get!(123)
      %Authorization{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Authorization, id)

  @doc """
  Creates a authorization.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Authorization{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    with {:ok, id} <- Snowflake.next_id() do
      %Authorization{}
      |> changeset(attrs)
      |> put_change(:id, Integer.to_string(id))
      |> Repo.insert()
    end
  end

  @doc """
  Updates a authorization.

  ## Examples

      iex> update(authorization, %{field: new_value})
      {:ok, %Authorization{}}

      iex> update(authorization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Authorization{} = authorization, attrs) do
    authorization
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a authorization.

  ## Examples

      iex> delete(authorization)
      {:ok, %Authorization{}}

      iex> delete(authorization)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Authorization{} = authorization) do
    Repo.delete(authorization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking authorization changes.

  ## Examples

      iex> change(authorization)
      %Ecto.Changeset{source: %Authorization{}}

  """
  def change(%Authorization{} = authorization) do
    changeset(authorization, %{})
  end

  defp changeset(%Authorization{} = authorization, attrs) do
    authorization
    |> cast(attrs, [:scope, :client_id, :user_id])
    |> validate_required([:scope, :client_id, :user_id])
  end
end
