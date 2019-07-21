defmodule TodoistBot.Application do
  use Application

  def start(_type, _args) do
    router =
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: TodoistBot.Api,
        options: [port: Application.fetch_env!(:todoist_bot, :app_port)]
      )

    children =
      case TodoistBot.Webhook.setup_webhook() do
        :ok ->
          [router]

        {:error, _} ->
          [TodoistBot.Poller, router]
      end

    opts = [strategy: :one_for_one, name: TodoistBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
