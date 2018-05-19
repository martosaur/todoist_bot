defmodule TodoistBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      TodoistBot.Poller,
      TodoistBot.Storage.Repo,
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
