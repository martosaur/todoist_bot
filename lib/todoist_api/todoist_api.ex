defmodule TodoistApi do
  alias TodoistBot.Interaction
  use HTTPoison.Base
  require Logger

  def refresh_access_token(%Interaction{} = i) do
    body = %{
      client_id: TodoistBot.Config.todoist_app_client_id(),
      client_secret: TodoistBot.Config.todoist_app_client_secret(),
      code: i.user.auth_code
    }

    case post("https://todoist.com/oauth/access_token", body, []) do
      {:ok, %{status_code: 200, body: body}} ->
        %{"access_token" => token} = Poison.decode!(body)
        Interaction.put_user_state(i, access_token: token)

      error ->
        Logger.error(
          "Could not get access token for user #{i.user.id}. Response: #{inspect(error)}"
        )

        i
        |> Interaction.put_user_state(auth_code: "", access_token: "")
        |> Interaction.new_user_state()
    end
  end

  def put_text_to_inbox(%Interaction{} = i) do
    body = %{
      content: i.request.text
    }

    case post("https://beta.todoist.com/api/v7/items/add", body, get_headers(i)) do
      {:ok, %{status_code: 200}} ->
        Interaction.put_resp_text(i, :task_added_text)

      error ->
        Logger.error("Could not add task for user #{i.user.id}. Response: #{inspect(error)}")
        Interaction.put_resp_text(i, :add_task_error_text)
    end
  end

  defp get_headers(%Interaction{} = i) do
    [
      {"Authorization", "Bearer #{i.user.access_token}"}
    ]
  end

  defp process_request_body(body) do
    body
    |> Poison.encode!()
  end

  defp process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers]
  end
end
