defmodule TodoistBot.Interaction.Response do
  alias __MODULE__

  defstruct chat_id: nil,
            text: "",
            reply_markup: nil,
            callback_query_id: nil,
            answer_callback_query_text: nil,
            message_id: nil,
            type: :none,
            parse_mode: nil

  def new(%{"callback_query" => %{}} = update) do
    %Response{
      chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
      callback_query_id: get_in(update, ["callback_query", "id"]),
      message_id: get_in(update, ["callback_query", "message", "message_id"])
    }
  end

  def new(update) do
    %Response{
      chat_id: get_in(update, ["message", "chat", "id"])
    }
  end
end
