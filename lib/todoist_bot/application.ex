defmodule TodoistBot.Application do
  use Application

  def start(_type, _args) do
    router =
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: TodoistBot.Api,
        options: [port: Application.fetch_env!(:todoist_bot, :app_port)]
      )

    opts = [strategy: :one_for_one, name: TodoistBot.Supervisor]
    Supervisor.start_link(children(router), opts)
  end
  
  if Mix.env() == :test do
    def children(router) do
      [router]
    end
    
  else
    def children(router) do
      poller_or_webhook =
        if Application.get_env(:todoist_bot, :use_webhook) == "true" do
          %{
            id: WebhookSetup,
            start: {TodoistBot.Webhook, :setup_webhook, []},
            restart: :transient
          }
        else
          TodoistBot.Poller
        end
      
      [
        %{
          id: WebhookCleanup,
          start: {TodoistBot.Webhook, :delete_webhook, []},
          restart: :transient
        },
        poller_or_webhook,
        router
      ]
    end
  end
end
