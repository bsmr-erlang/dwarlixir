defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "is replaced by a corpse (TODO 'all things that die')" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _locpid} = World.Location.start_link(%World.Location{id: loc_id, name: "center of the universe", description: "what's on the tin", pathways: []})
    {:ok, female_bird} = Mobs.Bird.birth(%{location_id: loc_id, lifespan: 0})

    bird_state = :sys.get_state(female_bird)
    controller = bird_state.controller_pid

    GenServer.cast(controller, :tick)
    # TODO oh good, sleeping
    Process.sleep 20
    contents = World.Location.look(loc_id)
    assert length(contents.items) == 1
  end

  test "giving birth results in an egg" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _locpid} = World.Location.start_link(%World.Location{id: loc_id, name: "center of the universe", description: "what's on the tin", pathways: []})
    {:ok, female_bird} = Mobs.Bird.birth(%{gender: :female, pregnant: true, ticks_to_birth: 1, location_id: loc_id, lifespan: 100})

    mob_state = :sys.get_state(female_bird)
    controller = mob_state.controller_pid
    GenServer.cast(controller, :tick)
    # TODO oh good, sleeping
    Process.sleep 500
    contents = World.Location.look(loc_id)
    IO.inspect contents
    assert length(contents.items) == 1
    assert (contents.items |> List.first) == "egg"
  end

end
