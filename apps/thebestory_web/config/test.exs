use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :thebestory_web, TheBestory.Web.Endpoint,
  http: [port: 4443],
  server: false
