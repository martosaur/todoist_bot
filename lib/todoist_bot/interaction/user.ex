defmodule TodoistBot.Interaction.User do
  alias __MODULE__
  use Ecto.Schema

  schema "users" do
    field(:telegram_id, :integer)
    field(:last_chat_id, :integer)
    field(:auth_code, :string, default: "")
    field(:auth_state, :string, default: "")
    field(:access_token, :string, default: "")
    field(:language, :string, default: "en")
    field(:delete, :boolean, virtual: true, default: false)
    field(:raw, :map, virtual: true)

    timestamps()
  end

  def new(%Nadia.Model.Update{callback_query: nil} = update) do
    %User{
      telegram_id: update.message.from.id,
      last_chat_id: update.message.chat.id,
      raw: update.message.from
    }
  end

  def new(%Nadia.Model.Update{message: nil} = update) do
    %User{
      telegram_id: update.callback_query.from.id,
      last_chat_id: update.callback_query.message.chat.id,
      raw: update.callback_query.from
    }
  end

  def new_state(%User{} = user) do
    auth_state = to_string(user.telegram_id) <> "." <> random_string()
    struct(user, auth_state: auth_state)
  end

  defp random_string do
    Enum.random(10_000_000_000..99_999_999_999) |> to_string()
  end
end
