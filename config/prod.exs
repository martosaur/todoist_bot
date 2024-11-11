import Config

config :todoist_bot, TodoistBot.Repo, busy_timeout: 10_000

config :disco_log,
  info_channel_id: "1305598685933211778",
  error_channel_id: "1305598736818241579"
