defmodule TodoistBot.Webhook do
  use Plug.Builder
  
  alias TodoistBot.Nadia.API

  plug(:check_webhook_enabled)
  plug(:check_token)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: {Jason, :decode!, [[keys: :atoms]]}
  )

  plug(:parse_update)
  plug(:invoke_processor)
  plug(:respond)
  
  def delete_webhook() do
    with :ok <- API.delete_webhook() do
      :ignore
    end
  end

  def setup_webhook do
    host = Application.fetch_env!(:todoist_bot, :app_host)
    path = Application.fetch_env!(:todoist_bot, :webhook_token)
    max_connections = Application.get_env(:todoist_bot, :webhook_max_connections, 40)
    url = host <> path

    with :ok <- API.set_webhook(url: url, max_connections: max_connections) do
      :ignore
    end
  end

  defp check_webhook_enabled(conn, _opts) do
    if Application.get_env(:todoist_bot, :use_webhook) != "true" do
      conn
      |> send_resp(404, "Page not found")
      |> halt()
    else
      conn
    end
  end

  defp check_token(conn, _opts) do
    if conn.params["token"] == Application.fetch_env!(:todoist_bot, :webhook_token) do
      conn
    else
      conn
      |> send_resp(404, "Page not found")
      |> halt()
    end
  end

  defp parse_update(conn, _opts) do
    conn
    |> assign(
      :update,
      Nadia.Parser.parse_result([conn.body_params], "getUpdates") |> List.first()
    )
  end

  defp invoke_processor(%{assigns: %{update: %Nadia.Model.Update{} = update}} = conn, _opts) do
    Task.start(TodoistBot.Processor, :process_message, [update])
    conn
  end

  defp respond(conn, _opts) do
    send_resp(conn, 200, "true")
  end
end
