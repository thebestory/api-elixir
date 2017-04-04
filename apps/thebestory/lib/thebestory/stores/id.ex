defmodule TheBestory.Stores.ID do
  import Ecto.{Query, Changeset}, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.ID

  @id_type "id"

  @doc """
  Return the list of ids.
  """
  def list,
    do: Repo.all(ID)

  @doc """
  Get a single id.
  """
  def get(id),
    do: Repo.get(ID, id)
  def get!(id),
    do: Repo.get!(ID, id)

  @doc """
  Generates a new id.
  """
  def generate(type \\ @id_type) do
    with {:ok, id} <- Snowflake.next_id() do
      sid = Integer.to_string(id)

      with {:ok, _} <- %ID{}
                       |> put_change(:id, sid)
                       |> put_change(:type, type)
                       |> Repo.insert()
      do
        {:ok, sid}
      else
        _ -> {:error, :id_not_generated}
      end
    end
  end

  @doc """
  Update id type.
  """
  def update(%ID{} = id, type \\ @id_type) do
    id
    |> put_change(:type, type)
    |> Repo.update()
  end
end
