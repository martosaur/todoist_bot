defmodule TodoistBot.Processor do
  alias TodoistBot.Storage
  alias TodoistBot.Interaction
  require Logger

  def process_message(nil), do: Logger.error("Processor received nil")

  def process_message(%Nadia.Model.Update{} = message) do
    try do
      message
      |> Interaction.new()
      |> TodoistBot.Storage.load_user()
      |> TodoistBot.Commands.match()
      |> save_user_state()
      |> send_response()
    rescue
      error -> Logger.warning(inspect(error))
    end
  end

  def send_notification(%Interaction{} = i) do
    try do
      send_response(i)
    rescue
      error -> Logger.warning(inspect(error))
    end
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
    options =
      [reply_markup: response.reply_markup, parse_mode: response.parse_mode]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.send_message(response.chat_id, response.text, options)
  end

  defp answer_callback_query(%Interaction.Response{} = response) do
    options =
      [text: response.answer_callback_query_text]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Task.start(fn -> Nadia.answer_callback_query(response.callback_query_id, options) end)
  end

  defp edit_message_reply_markup(%Interaction.Response{} = response) do
    options =
      [reply_markup: response.reply_markup]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.edit_message_reply_markup(response.chat_id, response.message_id, "", options)
  end

  defp edit_message_text(%Interaction.Response{} = response) do
    options =
      [reply_markup: response.reply_markup, parse_mode: response.parse_mode]
      |> Enum.reject(fn {_, v} -> v == nil end)

    Nadia.edit_message_text(response.chat_id, response.message_id, "", response.text, options)
  end

  defp save_user_state(%Interaction{} = i) do
    if i.user.delete do
      Storage.delete_user(i)
    else
      Storage.save_user(i)
    end
  end
end
