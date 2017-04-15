defmodule TheBestory.Stores.IDTest do
  use TheBestory.DataCase

  alias TheBestory.Stores

  @id_type "test"
  @default_id_type "id"

  test "get/1 returns the ID object by the given id" do
    {:ok, id} = Stores.ID.generate()
    assert Stores.ID.get(id.id) == id
  end

  test "get!/1 returns the ID object by the given id" do
    {:ok, id} = Stores.ID.generate()
    assert Stores.ID.get!(id.id) == id
  end

  test "generate/1 with id type generates an ID" do
    {:ok, id} = Stores.ID.generate(@id_type)

    assert is_integer(id.id)
    assert id.type == @id_type
  end

  test "generate/1 w/o type generates an ID with default type" do
    {:ok, id} = Stores.ID.generate()
    
    assert is_integer(id.id)
    assert id.type == @default_id_type
  end

  test "generate/1 with invalid type returns error" do
    assert {:error, :id_not_generated} = Stores.ID.generate(nil)
  end

  test "update/2 with a new type updates the ID" do
    {:ok, id} = Stores.ID.generate()

    assert {:ok, id} = Stores.ID.update(id, @id_type)
    assert id.type == @id_type
  end

  test "update/2 with invalid type returns error changeset" do
    {:ok, id} = Stores.ID.generate()

    assert {:error, %Ecto.Changeset{}} = Stores.ID.update(id, nil)
    assert Stores.ID.get!(id.id) == id
  end
end
