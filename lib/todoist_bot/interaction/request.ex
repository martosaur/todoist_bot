defmodule TodoistBot.Interaction.Request do
  alias __MODULE__

  defstruct raw: nil, chat_id: nil, text: "", callback: ""

  def new(%Nadia.Model.Update{callback_query: nil} = update) do
    %Request{
      raw: update,
      chat_id: update.message.chat.id,
      text: update.message.text
    }
  end

  def new(%Nadia.Model.Update{message: nil} = update) do
    %Request{
      raw: update,
      chat_id: update.callback_query.message.chat.id,
      callback: update.callback_query.data
    }
  end
end
