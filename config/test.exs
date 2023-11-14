import Config

config :todoist_bot,
  nadia_adapter: TodoistBot.Nadia.API.Mock,
  app_port: 9009,
  use_webhook: "true",
  app_host: "https://localhost/",
  webhook_token: "secret_token",
  todoist_app_client_id: "secret_client_id"