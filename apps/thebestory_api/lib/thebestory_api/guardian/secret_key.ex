defmodule TheBestory.API.Guardian.Serializer do
  def fetch, do: JOSE.JWK.generate_key({:rsa, 4096})
end
