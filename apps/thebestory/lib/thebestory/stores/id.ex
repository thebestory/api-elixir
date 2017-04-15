defmodule TheBestory.Stores.ID do
  import Ecto.Changeset, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.ID

  @id_type "id"

  @doc """
  Return the list of IDs.
  """
  def list,
    do: Repo.all(ID)

  @doc """
  Get a single ID.
  """
  def get(id),
    do: Repo.get(ID, id)
  def get!(id),
    do: Repo.get!(ID, id)

  @doc """
  Generate a new ID.
  """
  def generate(type \\ @id_type) do
    with {:ok, id} <- Snowflake.next_id(),
         {:ok, id} <- %ID{}
                      |> change
                      |> put_change(:id, id)
                      |> put_change(:type, type)
                      |> validate_required([:id, :type])
                      |> Repo.insert()
    do
      {:ok, id}
    else
      _ -> {:error, :id_not_generated}
    end
  end

  @doc """
  Update ID type.
  """
  def update(%ID{} = id, type) do
    id
    |> change
    |> put_change(:type, type)
    |> validate_required([:id, :type])
    |> Repo.update()
  end
end
