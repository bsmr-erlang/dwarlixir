defmodule GenericMobController do
  use GenServer

  @tick 1000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Registry.register(Registry.Tick, :subject_to_time, {__MODULE__, state.id})
    {:ok, state}
  end

  def handle_cast(:tick, state) do
    {:noreply, state}
  end

  # def handle_info(:tick, state) do
  #   # TODO more generic than "Dwarf" ?
  #   Mobs.Dwarf.tick(state.id)
  #   {:noreply, state}
  # end
end
