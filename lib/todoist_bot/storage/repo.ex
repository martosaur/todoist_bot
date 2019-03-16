defmodule TodoistBot.Storage.Repo do
  use Ecto.Repo, otp_app: :todoist_bot

  def init(_type, config) do
    config =
      config
      |> Keyword.put(:username, TodoistBot.Config.db_username())
      |> Keyword.put(:password, TodoistBot.Config.db_password())
      |> Keyword.put(:database, TodoistBot.Config.db_name())
      |> Keyword.put(:socket_dir, TodoistBot.Config.db_socket_dir())

    {:ok, config}
  end
end
