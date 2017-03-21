defmodule TheBestory.Application do
  @moduledoc """
  The TheBestory Application Service.

  The thebestory system business domain lives in this application.

  Exposes API to clients such as the `TheBestory.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(TheBestory.Repo, []),
    ], strategy: :one_for_one, name: TheBestory.Supervisor)
  end
end
