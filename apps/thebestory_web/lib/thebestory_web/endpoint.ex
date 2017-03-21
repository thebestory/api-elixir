defmodule TheBestory.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :thebestory_web

  # socket "/socket", TheBestory.Web.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :thebestory_web, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
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
    key: "_thebestory_web_key",
    signing_salt: "5KdWcwKA"

  plug TheBestory.Web.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    url_host = System.get_env("PHOENIX_URL_HOST") || raise "expected the PHOENIX_URL_HOST environment variable to be set"
    port = System.get_env("PHOENIX_PORT") || raise "expected the PHOENIX_PORT environment variable to be set"
    secret_key_base = System.get_env("PHOENIX_SECRET_KEY_BASE") || raise "expected the PHOENIX_SECRET_KEY_BASE environment variable to be set"

    {:ok, config
          |> Keyword.put(:url, [scheme: "https", host: url_host, port: 443])
          |> Keyword.put(:http, [:inet6, port: String.to_integer(port)])
          |> Keyword.put(:secret_key_base, secret_key_base)}
  end
end
