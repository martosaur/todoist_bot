defmodule TodoistBot.Processor do
  alias TodoistBot.Storage
  alias TodoistBot.Interaction
  alias TodoistBot.Telegram.API
  require Logger

  def process_message(nil), do: Logger.error("Processor received nil")

  def process_message(%{} = update) do
    update
    |> Interaction.new()
    |> TodoistBot.Storage.load_user()
    |> TodoistBot.Commands.match()
    |> save_user_state()
    |> send_response()
  end

  def send_notification(%Interaction{} = i) do
    send_response(i)
  end

  def send_response(%Interaction{response: response}) do
    case response.type do
      :message ->
        send_message(response)

      :edit_markup ->
        answer_callback_query(response)
        edit_message_reply_markup(response)

      :edit_text ->
        answer_callback_query(response)
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
    Task.start(fn ->
      params =
        Map.reject(
          %{
            callback_query_id: response.callback_query_id,
            text: response.answer_callback_query_text
          },
          fn {_, v} -> v == nil end
        )

      API.request("answer_callback_query", params)
    end)
  end

  defp edit_message_reply_markup(%Interaction.Response{} = response) do
    API.request("editMessageReplyMarkup", %{
      reply_markup: response.reply_markup
    })

    :ok
  end

  defp edit_message_text(%Interaction.Response{} = response) do
    params =
      Map.reject(
        %{
          reply_markup: response.reply_markup,
          parse_mode: response.parse_mode
        },
        fn {_, v} -> v == nil end
      )

    API.request("editMessageText", params)
    :ok
  end

  defp save_user_state(%Interaction{} = i) do
    if i.user.delete do
      Storage.delete_user(i)
    else
      Storage.save_user(i)
    end
  end
end
