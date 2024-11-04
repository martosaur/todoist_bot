defmodule TodoistBot.Commands do
  alias TodoistBot.Interaction
  require Logger

  def match(interaction) do
    case interaction do
      %{request: %{callback: "/unauthorized.back"}} ->
        interaction
        |> request_authorization()
        |> Interaction.put_resp_type_edit_markup()

      %{request: %{callback: "/logout.confirm.yes"}} ->
        interaction
        |> Interaction.put_resp_text("Who are you? Do I know you?")
        |> Interaction.set_user_to_delete()
        |> Interaction.put_resp_type_edit_text()

      %{request: %{text: "/help"}} ->
        interaction
        |> Interaction.put_resp_text("""
        /help - show this help
        /about - about this bot
        /logout - make this bot forget you
        """)
        |> Interaction.put_resp_parse_mode_markdown()
        |> Interaction.put_resp_type_message()

      %{request: %{text: "/about"}} ->
        interaction
        |> Interaction.put_resp_text(
          "*Telegram for Todoist* is a simple bot for adding Inbox tasks through Telegram. This bot is created by @martosaur and is not created by, affiliated with, or supported by Doist. If you want to contribute please see [this repo](https://github.com/martosaur/todoist_bot)"
        )
        |> Interaction.put_resp_parse_mode_markdown()
        |> Interaction.put_resp_type_message()

      %{request: %{text: "/logout"}} ->
        interaction
        |> Interaction.put_resp_text(
          "Are you sure you want to logout and disappear without a trace from this bot's life?"
        )
        |> Interaction.add_resp_inline_keyboard()
        |> Interaction.add_resp_inline_keyboard_row()
        |> Interaction.add_resp_inline_keyboard_callback_button(
          "Yes",
          "/logout.confirm.yes"
        )
        |> Interaction.put_resp_type_message()

      %{user: %{auth_code: code}, request: %{text: text}}
      when not is_nil(code) and not is_nil(text) ->
        interaction
        |> TodoistApi.refresh_access_token_if_needed()
        |> TodoistApi.put_text_to_inbox()
        |> Interaction.put_resp_type_message()

      %{user: %{auth_code: nil}} ->
        interaction
        |> request_authorization()
        |> Interaction.put_resp_type_message()

      _ ->
        interaction
        |> Interaction.put_resp_text("Did you say something?")
        |> Interaction.put_resp_type_message()
    end
  end

  def request_authorization(%Interaction{} = i) do
    i
    |> Interaction.put_resp_text("Please authorize this bot to access your account")
    |> Interaction.add_resp_inline_keyboard()
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_link_button(
      "Authorize on Todoist",
      "#{Application.fetch_env!(:todoist_bot, :app_host)}authorize?uuid=#{i.user.auth_state}"
    )
    |> Interaction.add_resp_inline_keyboard_row()
  end
end
