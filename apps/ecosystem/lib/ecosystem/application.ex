defmodule Ecosystem.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    GenServer.stop(:alarm_handler)

    children = [
      worker(Ecosystem, [%{}], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Ecosystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
