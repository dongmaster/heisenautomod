defmodule Heisenautomod.Init do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(FileLogger, []),
    ]

    opts = [strategy: :one_for_one, name: Heisenautomod.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
