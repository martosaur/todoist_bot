defmodule TodoistBot.Repo do
  use Ecto.Repo,
    otp_app: :todoist_bot,
    adapter: Ecto.Adapters.SQLite3
end
