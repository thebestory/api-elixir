use Mix.Config

config :thebestory, ecto_repos: [TheBestory.Repo]

# Configure database
config :thebestory, TheBestory.Repo,
  adapter: Ecto.Adapters.Postgres

# Configure snowflake generator
config :snowflake,
  nodes: ["127.0.0.1", :'nonode@nohost'],   # up to 1023 nodes
  epoch: 1483228800000  # don't change after you decide what your epoch is

import_config "#{Mix.env}.exs"
