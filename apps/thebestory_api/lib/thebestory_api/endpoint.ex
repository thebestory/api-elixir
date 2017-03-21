defmodule TheBestory.API.Endpoint do
  use Phoenix.Endpoint, otp_app: :thebestory_api

  # socket "/socket", TheBestory.API.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :thebestory_api, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_thebestory_api_key",
    signing_salt: "3ArZdAe5"

  plug TheBestory.API.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    url_host = System.get_env("URL_HOST") || raise "expected the URL_HOST environment variable to be set"
    port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
    secret_key_base = System.get_env("SECRET_KEY_BASE") || raise "expected the SECRET_KEY_BASE environment variable to be set"

    {:ok, config
          |> Keyword.put(:url, [scheme: "https", host: url_host, port: 443])
          |> Keyword.put(:http, [:inet6, port: String.to_integer(port)])
          |> Keyword.put(:secret_key_base, secret_key_base)}
  end
end
