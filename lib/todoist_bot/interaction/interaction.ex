defmodule TodoistBot.Interaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias TodoistBot.Interaction.User
  alias TodoistBot.Repo

  @primary_key false
  embedded_schema do
    embeds_one :request, Request do
      field(:raw, :map)
      field(:chat_id, :integer)
      field(:text, :string)
      field(:callback, :string)
    end

    embeds_one :response, Response do
      field(:chat_id, :integer)
      field(:callback_query_id, :string)
      field(:message_id, :integer)
      field(:text, :string)
      field(:reply_markup, :map)
      field(:answer_callback_query_text, :string)
      field(:type, Ecto.Enum, values: [:message, :edit_markup, :edit_text, :answer_callback])
      field(:parse_mode, :string)
    end

    field(:user, :map)
  end

  def from_update(%{"callback_query" => %{}} = update) do
    params = %{
      request: %{
        raw: update,
        chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
        callback: get_in(update["callback_query"]["data"])
      },
      response: %{
        chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
        callback_query_id: get_in(update, ["callback_query", "id"]),
        message_id: get_in(update, ["callback_query", "message", "message_id"])
      }
    }

    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:create)
  end

  def from_update(update) do
    params = %{
      request: %{
        raw: update,
        chat_id: get_in(update, ["message", "chat", "id"]),
        text: get_in(update["message"]["text"]) || get_in(update["message"]["caption"]) || ""
      },
      response: %{
        chat_id: get_in(update, ["message", "chat", "id"])
      }
    }

    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:create)
  end

  def changeset(interaction, attrs \\ %{}) do
    interaction
    |> change(attrs)
    |> cast_embed(:request, with: &request_changeset/2)
    |> cast_embed(:response, with: &response_changeset/2)
  end

  def request_changeset(request, attrs \\ %{}) do
    request
    |> cast(attrs, [:raw, :chat_id, :text, :callback])
    |> validate_required([:raw, :chat_id])
  end

  def response_changeset(response, attrs \\ %{}) do
    response
    |> cast(attrs, [:chat_id, :text, :callback])
    |> validate_required([:chat_id])
  end

  def load_user(interaction, update) do
    params =
      if interaction.request.callback do
        %{
          telegram_id: get_in(update, ["callback_query", "from", "id"]),
          last_chat_id: get_in(update, ["callback_query", "message", "chat", "id"]),
          raw: get_in(update["callback_query"]["from"])
        }
      else
        %{
          telegram_id: get_in(update, ["message", "from", "id"]),
          last_chat_id: get_in(update, ["message", "chat", "id"]),
          raw: get_in(update["message"]["from"])
        }
      end

    with {:ok, user} <-
           %User{}
           |> User.changeset(params)
           |> Repo.insert(
             on_conflict: {:replace, [:last_chat_id, :raw]},
             conflict_target: :telegram_id,
             returning: true
           ) do
      {:ok, %{interaction | user: user}}
    end
  end

  def notification(chat_id, text) do
    %Interaction{
      response: %TodoistBot.Interaction.Response{chat_id: chat_id},
      user: %TodoistBot.Interaction.User{}
    }
    |> put_resp_text(text)
    |> put_resp_type(:message)
  end

  def new_user_state(%Interaction{} = i) do
    user = TodoistBot.Interaction.User.new_state(i.user)
    put_in(i.user, user)
  end

  def put_user_state(%Interaction{} = i, fields \\ []) do
    user = struct(i.user, fields)
    put_in(i.user, user)
  end

  def put_resp_text(%Interaction{} = i, text), do: put_in(i.response.text, text)
  def put_resp_type(%Interaction{} = i, type), do: put_in(i.response.type, type)

  def put_resp_parse_mode_markdown(%Interaction{} = i),
    do: put_in(i.response.parse_mode, "Markdown")

  def add_resp_inline_keyboard(%Interaction{} = i) do
    put_in(i.response.reply_markup, %{inline_keyboard: []})
  end

  def add_resp_inline_keyboard_row(%Interaction{} = i) do
    keyboard = i.response.reply_markup.inline_keyboard

    put_in(i.response.reply_markup.inline_keyboard, keyboard ++ [[]])
  end

  def add_resp_inline_keyboard_link_button(%Interaction{} = i, text, link) do
    keyboard = i.response.reply_markup.inline_keyboard
    row = i.response.reply_markup.inline_keyboard |> List.last()
    button = %{text: text, url: link}

    put_in(
      i.response.reply_markup.inline_keyboard,
      List.replace_at(keyboard, -1, row ++ [button])
    )
  end

  def add_resp_inline_keyboard_callback_button(%Interaction{} = i, text, callback_data) do
    keyboard = i.response.reply_markup.inline_keyboard
    row = i.response.reply_markup.inline_keyboard |> List.last()
    button = %{text: text, callback_data: callback_data}

    put_in(
      i.response.reply_markup.inline_keyboard,
      List.replace_at(keyboard, -1, row ++ [button])
    )
  end
end
