defmodule TodoistBot.Api do
  use Plug.Router
  require Logger

  alias TodoistBot.User
  alias TodoistBot.Repo
  alias TodoistBot.Todoist

  @scope "task:add"

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/authorize" do
    conn = Plug.Conn.fetch_query_params(conn)

    state = conn.query_params["uuid"]
    app_client_id = Application.fetch_env!(:todoist_bot, :todoist_app_client_id)

    conn
    |> Plug.Conn.put_resp_header(
      "location",
      "https://todoist.com/oauth/authorize?client_id=#{app_client_id}&scope=#{@scope}&state=#{state}"
    )
    |> Plug.Conn.send_resp(301, "You're being redirected...")
  end

  get "/authorization/finish" do
    conn = Plug.Conn.fetch_query_params(conn)

    with nil <- conn.query_params["error"],
         auth_code <- conn.query_params["code"],
         auth_state <- conn.query_params["state"],
         {:ok, %User{} = user} <- complete_authorization(auth_code, auth_state) do
      Task.Supervisor.start_child(TodoistBot.TaskSupervisor, fn ->
        user.last_chat_id
        |> TodoistBot.Interaction.notification(
          "You have been succesfully authorized! Now simply drop me a message to create a new task"
        )
        |> TodoistBot.Processor.send_notification()
      end)

      Plug.Conn.send_resp(
        conn,
        200,
        "You have been succesfully authorized."
      )
    else
      error ->
        Logger.error("Authorization failed", extra: [error: error])

        Plug.Conn.send_resp(conn, 200, "Something went wrong")
    end
  end

  post("/:token/", to: TodoistBot.Webhook)

  match _ do
    send_resp(conn, 404, "Resource not found")
  end

  defp complete_authorization(auth_code, auth_state) do
    telegram_id =
      auth_state
      |> String.split(".")
      |> hd
      |> String.to_integer()

    with %User{} = user <- Repo.get(User, telegram_id),
         {:ok, %{status: 200, body: %{"access_token" => access_token}}} <-
           Todoist.API.get_access_token(auth_code),
         cs = User.changeset(user, %{auth_code: auth_code, access_token: access_token}) do
      Repo.update(cs)
    end
  end
end
