# Dwarlixir
* Travis ![Travis build](https://travis-ci.org/Trevoke/dwarlixir.svg?branch=master)
* Semaphore [![Build Status](https://semaphoreci.com/api/v1/trevoke/dwarlixir/branches/master/badge.svg)](https://semaphoreci.com/trevoke/dwarlixir)

## Getting started

Make sure you have Elixir ~> 1.5.1 available.

Clone the project. run `iex -S mix`. When the app starts, in another terminal, run `telnet localhost 4040`. you can type `look` and `quit`. AMAZING, IS IT NOT?

## Background
This project started off as the collision of two thoughts: "I want to build a MUD where each room is its own process" and "I bet I could build an amazing Dwarf Fortress clone in Elixir".

## Basic design

I read _multiple times_ through [the erlmud document](http://zxq9.com/erlmud/html/index.html), sometimes staring at a single sentence while trying to write the code, and I brought in more modern ideas where I thought they might make sense, such as the [`Registry`](https://hexdocs.pm/elixir/Registry.html#content) module and the concept of an [umbrella app](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html#umbrella-projects).


The basic goal is that everything is a process, in part because I think it works, in part because I really want to stretch my mind with this idea and take it as far as I can:

- A location is a process
- A mob is a process
- An item is a process
- Ticking is a process
- Etc.

One thing I learned is that you can't have two processes both send synchronous messages to each other at the same time, because that will cause a deadlock. When you write it that way it sounds kinda obvious, but since I'm doing a bunch of random actions, I have to say I never even thought about that.. Until the deadlocks. So, as a result, there are additional processes called `Pathways` which act as the "movement controller": Movement means that we remove the mob id from a location's state, add it to another location's state, and update the loc id in the mob's state. It's a bunch of synchronous messages and they should be handled by a third-party, so there's our third party. On the neat side of things, that means a location is a node, a pathway is an edge, and we have the makings of a proper graph.

## What to expect in the codebase

The basic code pattern I follow right now is something like this:

```elixir
defmodule Location do
  defstruct [
    :id, :name, :description, :pathways,
    corpses: [], mobs: %{}
  ]
  use GenServer

  def arrive(new_location, mob_id, public_info) do
    GenServer.call(via_tuple(new_location), {:arrive, mob_id, public_info})
  end

  def handle_call({:arrive, mob_id, public_info}, _from, state) do
    {:reply, :ok, %Location{state | mobs: Map.put(state.mobs, mob_id, public_info)}}
  end

  defp via_tuple(id) do
    {:via, Registry, {LocationRegistry, id}}
  end
end
```

In this way I use the `Location` namespace as:
- a [Struct](http://elixir-lang.org/getting-started/structs.html) (`defstruct`)
- the API for access to the [GenServer](https://hexdocs.pm/elixir/GenServer.html) process (`def arrive`)
- the actual message handling for the process (`def handle_call`)

Which might turn out to be too much code for one file in the future, and so I might break this apart into two or more namespaces.

## Tests

### End-to-end
There's a simple test for a user connecting via  TCP, looking, and quitting, right over here (this is not a link to master, so we can always see this test, even if it changes): https://github.com/Trevoke/dwarlixir/blob/f98a561/apps/connections/test/connections_test.exs#L5

### Pipelinable code... Maybe? (ECS?)
This is how reproduction works right now:
https://github.com/Trevoke/dwarlixir/blob/826de2cff64826ad8f8e82619f8d9b1a3de7646e/apps/mobs/lib/mobs/sexual_reproduction.ex

### Things dying
This is the simplest integration test I have yet. Ι need to work on this more, because right now I have a sleep in there to give the async messages time to get through.

The documentation for `Process.sleep/1` suggests sending a message back to the calling process, but I'm not sure this makes a lot of sense for me _in production_ because .. I think the messages would be sent back to the timer process that sends the tick message at a regular interval? So. Things in progress.
https://github.com/Trevoke/dwarlixir/blob/36c6c43d7e2d44d90c8e2863e41850a744e6c94c/apps/mobs/test/bird_test.exs
