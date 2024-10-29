defmodule TodoistBot.Interaction do
  alias __MODULE__
  alias TodoistBot.Strings

  defstruct request: nil, response: nil, user: nil

  def new(%{} = update) do
    %Interaction{
      request: TodoistBot.Interaction.Request.new(update),
      response: TodoistBot.Interaction.Response.new(update),
      user: TodoistBot.Interaction.User.new(update)
    }
  end

  def notification(chat_id, string_id, language) do
    %Interaction{
      response: %TodoistBot.Interaction.Response{chat_id: chat_id},
      user: %TodoistBot.Interaction.User{language: language}
    }
    |> put_resp_text(string_id)
    |> put_resp_type_message()
  end

  def authorized?(%Interaction{} = i) do
    i.user.auth_code != nil
  end

  def has_text?(%Interaction{} = i) do
    i.request.text != ""
  end

  def callback_query?(%Interaction{} = i) do
    i.request.callback != ""
  end

  def command?(%Interaction{} = i, command) do
    i.request.text == command
  end

  def new_user_state(%Interaction{} = i) do
    user = TodoistBot.Interaction.User.new_state(i.user)
    put_in(i.user, user)
  end

  def put_user_from_db(%Interaction{} = i, db_user) do
    put_in(i.user, db_user)
    |> put_user_state(
      last_chat_id: i.user.last_chat_id,
      raw: i.user.raw
    )
  end

  def put_user_state(%Interaction{} = i, fields \\ []) do
    user = struct(i.user, fields)
    put_in(i.user, user)
  end

  def put_resp_text(%Interaction{} = i, string_id) do
    text = Strings.get_string(string_id, i.user.language)
    put_in(i.response.text, text)
  end

  def put_resp_answer_callback_text(%Interaction{} = i, string_id) do
    text = Strings.get_string(string_id, i.user.language)
    put_in(i.response.answer_callback_query_text, text)
  end

  def put_resp_type_message(%Interaction{} = i) do
    put_in(i.response.type, :message)
  end

  def put_resp_type_edit_markup(%Interaction{} = i) do
    put_in(i.response.type, :edit_markup)
  end

  def put_resp_type_edit_text(%Interaction{} = i) do
    put_in(i.response.type, :edit_text)
  end

  def put_resp_type_answer_callback(%Interaction{} = i) do
    put_in(i.response.type, :answer_callback)
  end

  def put_resp_parse_mode_markdown(%Interaction{} = i) do
    put_in(i.response.parse_mode, "Markdown")
  end

  def add_resp_inline_keyboard(%Interaction{} = i) do
    put_in(i.response.reply_markup, %{inline_keyboard: []})
  end

  def add_resp_inline_keyboard_row(%Interaction{} = i) do
    keyboard = i.response.reply_markup.inline_keyboard

    put_in(i.response.reply_markup.inline_keyboard, keyboard ++ [[]])
  end

  def add_resp_inline_keyboard_link_button(%Interaction{} = i, string_id, link) do
    keyboard = i.response.reply_markup.inline_keyboard
    row = i.response.reply_markup.inline_keyboard |> List.last()
    text = Strings.get_string(string_id, i.user.language)
    button = %{text: text, url: link}

    put_in(
      i.response.reply_markup.inline_keyboard,
      List.replace_at(keyboard, -1, row ++ [button])
    )
  end

  def add_resp_inline_keyboard_callback_button(%Interaction{} = i, string_id, callback_data) do
    keyboard = i.response.reply_markup.inline_keyboard
    row = i.response.reply_markup.inline_keyboard |> List.last()
    text = Strings.get_string(string_id, i.user.language)
    button = %{text: text, callback_data: callback_data}

    put_in(
      i.response.reply_markup.inline_keyboard,
      List.replace_at(keyboard, -1, row ++ [button])
    )
  end

  def set_user_to_delete(%Interaction{} = i) do
    put_in(i.user.delete, true)
  end
end
