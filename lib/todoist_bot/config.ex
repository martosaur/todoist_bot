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
    case System.get_env("TODOIST_ADDRESS") do
      nil ->
        "http://example.com/"

      s ->
        s
    end
  end

  def todoist_app_client_id do
    result =
      case System.get_env("TODOIST_CLIENT_ID") do
        nil ->
          ""

        s ->
          s
      end

    if Mix.env() == :test, do: "test", else: result
  end

  def todoist_app_client_secret do
    result =
      case System.get_env("TODOIST_CLIENT_SECRET") do
        nil ->
          ""

        s ->
          s
      end

    if Mix.env() == :test, do: "test", else: result
  end

  def db_url do
    case System.get_env("DATABASE_URL") do
      nil ->
        ""

      s ->
        s
    end
  end

  def db_ssl do
    case Mix.env() do
      :dev -> false
      :test -> false
      _ -> true
    end
  end

  def bot_metrics_token do
    case System.get_env("BOT_METRICS_TOKEN") do
      nil ->
        ""

      s ->
        s
    end
  end
end
