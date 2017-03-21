use Mix.Config

# Configure database
config :thebestory, TheBestory.Repo,
  username: "postgres",
  password: "postgres",
  database: "thebestory_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
