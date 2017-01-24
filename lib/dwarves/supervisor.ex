defmodule Dwarves.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Registry, [:unique, Dwarves.World], id: :world), # spawn, move, loc_open?
      worker(Registry, [:duplicate, Registry.Dwarves], id: :dwarves),
      worker(Dwarves.Spawn, [[]], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
