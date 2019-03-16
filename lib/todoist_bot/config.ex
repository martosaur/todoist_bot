defmodule TodoistBot.Config do
  def app_port do
    case System.get_env("PORT") do
      nil ->
        4000

      s ->
        String.to_integer(s)
    end
  end

  def app_host do
    result = System.get_env("TODOIST_ADDRESS") || "http://example.com"

    if Mix.env() == :test, do: "http://example.com", else: result
  end

  def todoist_app_client_id do
    result = System.get_env("TODOIST_CLIENT_ID") || ""

    if Mix.env() == :test, do: "test", else: result
  end

  def todoist_app_client_secret do
    result = System.get_env("TODOIST_CLIENT_SECRET") || ""

    if Mix.env() == :test, do: "test", else: result
  end

  def db_username do
    System.get_env("DATABASE_USERNAME") || ""
  end

  def db_password do
    System.get_env("DATABASE_PASSWORD") || ""
  end

  def db_name do
    System.get_env("DATABASE_NAME") || ""
  end

  def db_socket_dir do
    System.get_env("DATABASE_SOCKET_DIR") || ""
  end

  def bot_metrics_token do
    System.get_env("BOT_METRICS_TOKEN") || ""
  end
end
