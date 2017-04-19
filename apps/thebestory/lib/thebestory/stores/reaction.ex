defmodule TheBestory.Stores.Reaction do
  import Ecto.Changeset, warn: false

  alias TheBestory.Repo
  alias TheBestory.Schema.Reaction
  alias TheBestory.Schema.User
  alias TheBestory.Stores

  @id_type "reaction"

  @doc """
  Return the list of reactions.
  """
  def list,
    do: Repo.all(Reaction)

  @doc """
  Get a single reaction.
  """
  def get(id),
    do: Repo.get(Reaction, id)
  def get!(id),
    do: Repo.get!(Reaction, id)

  @doc """
  Get a single valid reaction by it's user and object ids.
  """
  def get_valid_by_user_and_object(%User{} = user, %{id: object_id} = _object),
    do: Repo.get_by(Reaction, user: user, object_id: object_id, valid: true)
  def get_valid_by_user_and_object!(%User{} = user, %{id: object_id} = _object),
    do: Repo.get_by!(Reaction, user: user, object_id: object_id, valid: true)

  @doc """
  Create a reaction.
  """
  def create(%{user: %User{} = user, 
               object: %{id: _} = object} = _attrs) do
    Repo.transaction(fn ->
      with {:ok, id}       <- Stores.ID.generate(@id_type),
           {:ok, reaction} <- %Reaction{}
                              |> put_change(:id, id)
                              |> put_change(:user_id, user.id)
                              |> put_change(:object_id, object.id)
                              |> put_change(:added_at, DateTime.utc_now())
                              |> Repo.insert(),
           {:ok, _}        <- Stores.User.increment_reactions_count(user)
      do
        reaction
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Delete the reaction.
  """
  def delete(%Reaction{valid: true} = reaction) do
    Repo.transaction(fn ->
      with {:ok, user}     <- Stores.User.get(reaction.user_id),
           {:ok, reaction} <- reaction
                              |> put_change(:valid, false)
                              |> put_change(:removed_at, DateTime.utc_now())
                              |> Repo.update(),
           {:ok, _}        <- Stores.User.decrement_reactions_count(user)
      do
        reaction
      else
        _ -> Repo.rollback(:reaction_not_deleted)
      end
    end)
  end
end
