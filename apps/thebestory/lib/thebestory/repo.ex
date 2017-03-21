defmodule TheBestory.Repo do
  use Ecto.Repo, otp_app: :thebestory

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    case Mix.env do
      :prod ->
        {:ok, opts 
              |> Keyword.put(:url, System.get_env("DATABASE_URL") || raise "expected the DATABASE_URL environment variable to be set") 
              |> Keyword.put(:pool_size, String.to_integer(System.get_env("DATABASE_POOL_SIZE") || raise "expected the DATABASE_POOL_SIZE environment variable to be set"))}
      _ -> 
        {:ok, opts}
    end
  end
end
