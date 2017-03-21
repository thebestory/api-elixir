use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :thebestory_api, TheBestory.API.Endpoint,
  http: [port: 4444],
  server: false
