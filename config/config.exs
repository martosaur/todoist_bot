import Config

config :todoist_bot,
  telegram_adapter: Req

import_config "#{Mix.env()}.exs"
