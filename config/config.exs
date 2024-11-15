import Config

config :todoist_bot, TodoistBot.Repo,
  database: Path.expand("../#{config_env()}.db", Path.dirname(__ENV__.file)),
  cache_size: -2000,
  pool_size: 10

config :todoist_bot,
  telegram_adapter: Req,
  todoist_adapter: Req,
  ecto_repos: [TodoistBot.Repo]

config :disco_log,
  otp_app: :todoist_bot,
  guild_id: "1302395532735414282",
  category_id: "1302398119195181127",
  occurrences_channel_id: "1302398120206008371",
  occurrences_channel_tags: %{
    "plug" => "1302398120206008372",
    "live_view" => "1302398120206008373",
    "oban" => "1302398120206008374"
  },
  info_channel_id: "1302398121430618174",
  error_channel_id: "1302398123011739748",
  metadata: [:extra]

import_config "#{Mix.env()}.exs"
