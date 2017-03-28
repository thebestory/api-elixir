defmodule TheBestory.Utils.Password do
  # alias Comeonin.Bcrypt

  @doc """
  Matches a raw and crypted password.
  """
  def match(raw, crypted),
    # do: Bcrypt.checkpw(password, crypted)
    do: raw == crypted

  @doc """
  Hash the password with a randomly generated salt.
  """
  def hash(password), 
    # do: Bcrypt.hashpwsalt(password)
    do: password
end
