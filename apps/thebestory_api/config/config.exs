# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :thebestory_api,
  namespace: TheBestory.API,
  ecto_repos: []

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

config :authable,
  ecto_repos: [],
  repo: TheBestory.Repo,
  resource_owner: TheBestory.Schema.User,
  token_store: TheBestory.Schema.Token,
  client: TheBestory.Schema.Application,
  app: TheBestory.Schema.Authorization,
  expires_in: %{
    access_token: 24 * 60 * 60,
    refresh_token: 7 * 24 * 60 * 60,
    authorization_code: 60 * 60,
    session_token: 30 * 24 * 60 * 60
  },
  grant_types: %{
    authorization_code: Authable.GrantType.AuthorizationCode,
    client_credentials: Authable.GrantType.ClientCredentials,
    password: Authable.GrantType.Password,
    refresh_token: Authable.GrantType.RefreshToken
  },
  auth_strategies: %{
    headers: %{
      "authorization" => [
        {~r/Basic ([a-zA-Z\-_\+=]+)/, Authable.Authentication.Basic},
        {~r/Bearer ([a-zA-Z\-_\+=]+)/, Authable.Authentication.Bearer},
      ],
      "x-api-token" => [
        {~r/([a-zA-Z\-_\+=]+)/, Authable.Authentication.Bearer}
      ]
    },
    query_params: %{
      "access_token" => Authable.Authentication.Bearer
    },
    sessions: %{
      "session_token" => Authable.Authentication.Session
    }
  },
  scopes: ~w(read write),
  renderer: Authable.Renderer.RestApi

config :authable, Authable.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "",
  password: "",
  database: "",
  hostname: "",
  pool_size: 10

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
