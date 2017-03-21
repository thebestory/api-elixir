use Mix.Config

# Configure database
config :thebestory, TheBestory.Repo,
  username: "postgres",
  password: "postgres",
  database: "thebestory_dev",
  hostname: "localhost",
  pool_size: 10
