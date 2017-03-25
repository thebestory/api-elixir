# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :thebestory_api,
  namespace: TheBestory.API,
  ecto_repos: [TheBestory.Repo]

# Configures the endpoint
config :thebestory_api, TheBestory.API.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qsIFEOFKCu99i5GbwBxUEn3aB3VyOA3qWWQA+sAwDH6bgRr1W3qGtA47yx7G4snq",
  render_errors: [view: TheBestory.API.ErrorView, accepts: ~w(json)],
  pubsub: [name: TheBestory.API.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,

  verify_module: Guardian.JWT,  # optional
  issuer: "The Bestory Project",
  ttl: {7, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "woiuerojksldkjoierwoiejrlskjdf",
  serializer: TheBestory.API.Guardian.Serializer

config :guardian_db, GuardianDb,
  repo: TheBestory.Repo,
  schema_name: "guardian_tokens", # Optional, default is "guardian_tokens"
  sweep_interval: 120 # 120 minutes

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
