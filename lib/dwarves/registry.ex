defmodule Dwarves.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :dwarves_registry)
  end

  def init(opts) do
    Registry.start_link(:duplicate, Registry.Test, partitions: System.schedulers_online)
  end

  def send_heartbeat do
    Registry.dispatch(Registry.Test, :subject_to_time, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, {:be})
    end)
  end

  def add(key, value) do
    Registry.register(Registry.Test, key, value)
  end

  def handle_info({:send_heartbeat}, state) do
    send_heartbeat()
    {:noreply, state}
  end
end
