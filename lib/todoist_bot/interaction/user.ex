defmodule TodoistBot.Interaction.User do
  alias __MODULE__

  defstruct id: nil,
            raw: nil,
            auth_code: "",
            auth_state: "",
            access_token: "",
            last_chat_id: nil,
            language: "en",
            delete: false

  def new(%Nadia.Model.Update{callback_query: nil} = update) do
    %User{
      id: update.message.from.id,
      last_chat_id: update.message.chat.id,
      raw: update.message.from
    }
  end

  def new(%Nadia.Model.Update{message: nil} = update) do
    %User{
      id: update.callback_query.from.id,
      last_chat_id: update.callback_query.message.chat.id,
      raw: update.callback_query.from
    }
  end

  def new_state(%User{} = user) do
    auth_state = to_string(user.id) <> "." <> random_string()
    struct(user, auth_state: auth_state)
  end

  defp random_string do
    Enum.random(10_000_000_000..99_999_999_999) |> to_string()
  end
end
