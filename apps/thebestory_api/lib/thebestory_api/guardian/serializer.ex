defmodule TheBestory.API.Guardian.Serializer do
  @behaviour Guardian.Serializer

  alias TheBestory.Schema.User
  alias TheBestory.Store

  def for_token(user = %User{}), do: {:ok, "user:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("user:" <> id), do: {:ok, Store.User.get(id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
