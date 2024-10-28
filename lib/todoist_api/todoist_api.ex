defmodule TodoistApi do
  alias TodoistBot.Interaction
  require Logger

  def refresh_access_token_if_needed(%Interaction{user: %Interaction.User{access_token: ""}} = i) do
    body = %{
      client_id: Application.fetch_env!(:todoist_bot, :todoist_app_client_id),
      client_secret: Application.fetch_env!(:todoist_bot, :todoist_app_client_secret),
      code: i.user.auth_code
    }

    case Req.post("https://todoist.com/oauth/access_token", json: body) do
      {:ok, %{status: 200, body: %{"access_token" => token}}} ->
        Interaction.put_user_state(i, access_token: token)

      error ->
        Logger.error(
          "Could not get access token for user #{i.user.telegram_id}. Response: #{inspect(error)}"
        )

        i
    end
  end

  def refresh_access_token_if_needed(%Interaction{} = i), do: i

  def put_text_to_inbox(%Interaction{} = i) do
    body = %{
      content: i.request.text
    }

    case Req.post("https://api.todoist.com/rest/v2/tasks",
           json: body,
           auth: {:bearer, i.user.access_token}
         ) do
      {:ok, %{status: 200}} ->
        Interaction.put_resp_text(i, :task_added_text)

      {:ok, %{status: 403} = resp} ->
        Logger.error(
          "Could not add task for user #{i.user.telegram_id}. Response: #{inspect(resp)}"
        )

        i
        |> Interaction.put_user_state(auth_code: "", access_token: "")
        |> Interaction.new_user_state()
        |> TodoistBot.Commands.request_authorization()
        |> Interaction.put_resp_text(:error_403_text)

      {_, error} ->
        Logger.error(
          "Could not add task for user #{i.user.telegram_id}. Response: #{inspect(error)}"
        )

        Interaction.put_resp_text(i, :add_task_error_text)
    end
  end
end
