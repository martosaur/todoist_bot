import Config

config :todoist_bot, TodoistBot.Repo,
  database: Path.expand("../#{config_env()}.db", Path.dirname(__ENV__.file)),
  cache_size: -2000,
  pool_size: 10

config :todoist_bot,
  telegram_adapter: Req,
  ecto_repos: [TodoistBot.Repo]

import_config "#{Mix.env()}.exs"
