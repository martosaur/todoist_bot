import Config

if config_env() == :prod do
  config :todoist_bot, TodoistBot.Repo, database: System.fetch_env!("DB_PATH")

  config :disco_log,
    token: System.fetch_env!("DISCO_LOG_TOKEN"),
    info_channel_id: System.fetch_env!("DISCO_INFO_CHANNEL_ID"),
    error_channel_id: System.fetch_env!("DISCO_ERROR_CHANNEL_ID")

  config :todoist_bot,
    bot_token: System.fetch_env!("BOT_TOKEN"),
    app_port: System.fetch_env!("APP_PORT") |> String.to_integer(),
    app_host: System.fetch_env!("APP_HOST"),
    todoist_app_client_id: System.fetch_env!("TODOIST_APP_CLIENT_ID"),
    todoist_app_client_secret: System.fetch_env!("TODOIST_APP_CLIENT_SECRET"),
    use_webhook: System.get_env("USE_WEBHOOK", "false"),
    webhook_token: System.get_env("WEBHOOK_TOKEN", "mytoken"),
    webhook_url: System.get_env("WEBHOOK_URL", "https://localhost/"),
    webhook_max_connections:
      System.get_env("WEBHOOK_MAX_CONNECTIONS", "40") |> String.to_integer()
end
