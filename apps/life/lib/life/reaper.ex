defmodule Life.Reaper do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def claim(mob_id, loc_id, public_info) do
    GenServer.cast(__MODULE__, {:claim, mob_id, loc_id, public_info})
  end

  def handle_cast({:claim, mob_id, loc_id, public_info}, state) do
    IO.puts "process-level reaping"
    corpse_id = UUID.uuid4(:hex)
    corpse_state = Map.put(public_info, :id, corpse_id)
    World.Location.depart(loc_id, mob_id)
    Dwarf.stop(mob_id)
    IO.inspect corpse_state
    Item.Supervisor.create(:corpse, loc_id, corpse_state)
    {:noreply, state}
  end
end
