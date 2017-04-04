defmodule TheBestory.Stores.Reaction do
  import Ecto.{Query, Changeset}, warn: false

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
               object: %{id: object_id} = _object} = _attrs) do
    Repo.transaction(fn ->
      with {:ok, id} <- Stores.ID.generate(@id_type) do
        with {:ok, reaction} <- %Reaction{}
                                |> put_assoc(:user, user)
                                |> put_change(:object_id, object_id)
                                |> put_change(:id, id)
                                |> Repo.insert(),
             {:ok, _} <- Stores.User.increment_reactions_count(user)
        do
          {:ok, reaction}
        else
          _ -> Repo.rollback(:reaction_not_created)
        end
      else
        _ -> Repo.rollback(:reaction_not_created)
      end
    end)
  end

  @doc """
  Invalidate a reaction.
  """
  def invalidate(%Reaction{valid: true} = reaction) do
    Repo.transaction(fn ->
      with {:ok, reaction} <- reaction
                              |> put_change(:valid, false)
                              |> Repo.update(),
           {:ok, _} <- Stores.User.decrement_reactions_count(reaction.user)
      do
        {:ok, reaction}
      else
        _ -> Repo.rollback(:reaction_not_invalidated)
      end
    end)
  end

  @doc """
  Invalidate a reaction.
  """
  def delete(%Reaction{valid: true} = reaction),
    do: invalidate(reaction)
end
