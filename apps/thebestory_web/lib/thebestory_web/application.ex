defmodule TheBestory.Web.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheBestory.Web.Supervisor]

    case System.get_env("SERVER_TYPE") do
      "api" -> 
        Supervisor.start_link([], opts)
      "web" ->
        # Define workers and child supervisors to be supervised
        children = [
          # Start the endpoint when the application starts
          supervisor(TheBestory.Web.Endpoint, []),
          # Start your own worker by calling: TheBestory.Web.Worker.start_link(arg1, arg2, arg3)
          # worker(TheBestory.Web.Worker, [arg1, arg2, arg3]),
        ]

        Supervisor.start_link(children, opts)
      _ -> 
        Supervisor.start_link([], opts)
    end
  end
end
