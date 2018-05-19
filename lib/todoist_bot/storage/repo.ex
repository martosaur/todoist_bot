defmodule TodoistBot.Storage.Repo do
  use Ecto.Repo, otp_app: :todoist_bot

  def init(_type, config) do
    config =
      config
      |> Keyword.put(:url, TodoistBot.Config.db_url())
      |> Keyword.put(:ssl, TodoistBot.Config.db_ssl())

    {:ok, config}
  end
end
