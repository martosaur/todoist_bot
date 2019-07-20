import Config

config :nadia, token: System.fetch_env!("NADIA_BOT_TOKEN")

config :todoist_bot,
  app_port: System.fetch_env!("APP_PORT") |> String.to_integer(),
  app_host: System.fetch_env!("APP_HOST"),
  todoist_app_client_id: System.fetch_env!("TODOIST_APP_CLIENT_ID"),
  todoist_app_client_secret: System.fetch_env!("TODOIST_APP_CLIENT_SECRET"),
  dets_file: System.fetch_env!("DETS_FILE")
