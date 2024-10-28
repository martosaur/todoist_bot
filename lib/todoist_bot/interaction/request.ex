defmodule TodoistBot.Interaction.Request do
  alias __MODULE__

  defstruct raw: nil, chat_id: nil, text: "", callback: ""

  def new(%{"callback_query" => %{}} = update) do
    %Request{
      raw: update,
      chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
      callback: get_in(update["callback_query"]["data"])
    }
  end

  def new(update) do
    %Request{
      raw: update,
      chat_id: get_in(update, ["message", "chat", "id"]),
      text: get_in(update["message"]["text"]) || get_in(update["message"]["caption"]) || ""
    }
  end
end
