defmodule TodoistBot.Interaction.Request do
  alias __MODULE__

  defstruct raw: nil, chat_id: nil, text: "", callback: ""

  # Nadia.Model.Update
  def new(%{callback_query: nil} = update) do
    %Request{
      raw: update,
      chat_id: update.message.chat.id,
      text: update.message.text || update.message.caption || ""
    }
  end

  # Nadia.Model.Update
  def new(%{message: nil} = update) do
    %Request{
      raw: update,
      chat_id: update.callback_query.message.chat.id,
      callback: update.callback_query.data
    }
  end
end
