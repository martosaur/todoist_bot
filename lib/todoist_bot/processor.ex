defmodule TodoistBot.Processor do
  alias TodoistBot.Commands
  alias TodoistBot.Interaction
  alias TodoistBot.Telegram.API
  require Logger

  def process_message(%{} = update) do
    with {:ok, interaction} <- Interaction.from_update(update),
         {:ok, interaction} <- Interaction.load_user(interaction, update) do
      interaction
      |> Commands.match()
      |> send_response()
    end
  end

  def send_notification(%Interaction{} = i) do
    send_response(i)
  end

  def send_response(%Interaction{response: response}) do
    case response.type do
      :message ->
        send_message(response)

      :edit_text ->
        Task.Supervisor.start_child(TodoistBot.TaskSupervisor, fn ->
          answer_callback_query(response)
        end)

        edit_message_text(response)

      :answer_callback ->
        answer_callback_query(response)
    end
  end

  defp send_message(%Interaction.Response{} = response) do
    params =
      Map.reject(
        %{
          chat_id: response.chat_id,
          text: response.text,
          reply_markup: response.reply_markup,
          parse_mode: response.parse_mode
        },
        fn {_, v} -> v == nil end
      )

    API.request("sendMessage", params)
  end

  defp answer_callback_query(%Interaction.Response{} = response) do
    params =
      Map.reject(
        %{
          callback_query_id: response.callback_query_id,
          text: response.answer_callback_query_text
        },
        fn {_, v} -> v == nil end
      )

    API.request("answerCallbackQuery", params)
  end

  defp edit_message_text(%Interaction.Response{} = response) do
    params =
      Map.reject(
        %{
          chat_id: response.chat_id,
          message_id: response.message_id,
          text: response.text,
          reply_markup: response.reply_markup,
          parse_mode: response.parse_mode
        },
        fn {_, v} -> v == nil end
      )

    API.request("editMessageText", params)
    :ok
  end
end
