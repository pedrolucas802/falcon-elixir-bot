defmodule FalconBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      {FalconBot, []}
    ]

    opts = [strategy: :one_for_one, name: FalconBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
