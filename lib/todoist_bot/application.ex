defmodule TodoistBot.Application do
  use Application

  def start(_type, _args) do
    :ets.new(:users, [:set, :public, :named_table])

    children = [
      TodoistBot.Poller,
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: TodoistBot.Api,
        options: [port: TodoistBot.Config.app_port()]
      )
    ]

    opts = [strategy: :one_for_one, name: TodoistBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
