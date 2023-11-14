import Config

config :todoist_bot,
  nadia_adapter: Nadia

import_config "#{Mix.env()}.exs"
