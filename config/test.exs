import Config

config :todoist_bot, TodoistBot.Repo,
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :todoist_bot,
  bot_token: "mytoken",
  telegram_adapter: TodoistBot.Telegram.API.Mock,
  todoist_adapter: TodoistBot.Todoist.API.Mock,
  app_port: 9009,
  use_webhook: "true",
  app_host: "https://localhost/",
  webhook_token: "secret_token",
  todoist_app_client_id: "secret_client_id"

config :disco_log,
  enable: false
