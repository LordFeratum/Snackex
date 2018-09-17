defmodule Snackex do
  use Application

  require Logger

  import Supervisor.Spec

  def start(_type, _args) do
    token = Telex.Config.get(:snackex, :token)

    children = [
      supervisor(Telex, []),
      supervisor(Snackex.Storage, []),
      supervisor(Snackex.Bot, [:polling, token])
    ]

    opts = [strategy: :one_for_one, name: Snackex]

    case Supervisor.start_link(children, opts) do
      {:ok, _} = ok ->
        Logger.info("Starting Snackex")
        ok

      error ->
        Logger.info("Error starting Snackex")
        error
    end
  end
end
