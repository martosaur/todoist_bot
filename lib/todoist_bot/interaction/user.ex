defmodule TodoistBot.Interaction.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @primary_key {:telegram_id, :id, autogenerate: false}
  schema "users" do
    field(:last_chat_id, :integer)
    field(:auth_code, :string)
    field(:auth_state, :string)
    field(:access_token, :string)
    field(:delete, :boolean, default: false)
    field(:raw, :map, default: %{})

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :telegram_id,
      :last_chat_id,
      :auth_code,
      :auth_state,
      :access_token,
      :delete,
      :raw
    ])
    |> validate_required([:telegram_id])
  end

  def new(%{"callback_query" => %{}} = update) do
    %User{
      telegram_id: get_in(update, ["callback_query", "from", "id"]),
      last_chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
      raw: get_in(update["callback_query"]["from"])
    }
  end

  def new(update) do
    %User{
      telegram_id: get_in(update, ["message", "from", "id"]),
      last_chat_id: get_in(update, ["message", "chat", "id"]),
      raw: get_in(update["message"]["from"])
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
