defmodule TodoistBot.Api do
  use Plug.Router

  @scope "task:add"

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/authorize" do
    conn = Plug.Conn.fetch_query_params(conn)

    state = conn.query_params["uuid"]
    language = conn.query_params["language"] || "en"

    conn
    |> Plug.Conn.put_resp_header(
      "location",
      "https://todoist.com/oauth/authorize?client_id=#{TodoistBot.Config.todoist_app_client_id()}&scope=#{
        @scope
      }&state=#{state}"
    )
    |> Plug.Conn.send_resp(301, TodoistBot.Strings.get_string(:redirecting_web, language))
  end

  get "/authorization/finish" do
    conn = Plug.Conn.fetch_query_params(conn)

    with nil <- conn.query_params["error"],
         auth_code <- conn.query_params["code"],
         auth_state <- conn.query_params["state"],
         {:ok, notify_chat_id, language} <-
           TodoistBot.Storage.complete_authorization(auth_code, auth_state) do
      Task.start(fn ->
        notify_chat_id
        |> TodoistBot.Interaction.notification(:authorization_success_text, language)
        |> TodoistBot.Processor.send_notification()
      end)

      Plug.Conn.send_resp(
        conn,
        200,
        TodoistBot.Strings.get_string(:authorization_success_web, language)
      )
    else
      _ ->
        Plug.Conn.send_resp(conn, 200, "Something went wrong")
    end
  end

  match _ do
    send_resp(conn, 404, "Resource not found")
  end
end
