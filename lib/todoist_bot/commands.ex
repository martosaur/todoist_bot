defmodule TodoistBot.Commands do
  alias TodoistBot.Interaction
  require Logger

  def match(%Interaction{} = i) do
    if Interaction.callback_query?(i) do
      case i.request.callback do
        "/unauthorized.back" ->
          i
          |> request_authorization()
          |> Interaction.put_resp_type_edit_markup()

        "/logout.confirm.yes" ->
          i
          |> Interaction.put_resp_text("Who are you? Do I know you?")
          |> Interaction.set_user_to_delete()
          |> Interaction.put_resp_type_edit_text()
      end
    else
      cond do
        Interaction.command?(i, "/help") ->
          i
          |> Interaction.put_resp_text("""
          /help - show this help
          /about - about this bot
          /logout - make this bot forget you
          """)
          |> Interaction.put_resp_parse_mode_markdown()
          |> Interaction.put_resp_type_message()

        Interaction.command?(i, "/about") ->
          i
          |> Interaction.put_resp_text(
            "*Telegram for Todoist* is a simple bot for adding Inbox tasks through Telegram. This bot is created by @martosaur and is not created by, affiliated with, or supported by Doist. If you want to contribute please see [this repo](https://github.com/martosaur/todoist_bot)"
          )
          |> Interaction.put_resp_parse_mode_markdown()
          |> Interaction.put_resp_type_message()

        Interaction.command?(i, "/logout") ->
          i
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

        Interaction.authorized?(i) && Interaction.has_text?(i) ->
          i
          |> TodoistApi.refresh_access_token_if_needed()
          |> TodoistApi.put_text_to_inbox()
          |> Interaction.put_resp_type_message()

        Interaction.authorized?(i) ->
          i
          |> Interaction.put_resp_text("Did you say something?")
          |> Interaction.put_resp_type_message()

        true ->
          i
          |> request_authorization()
          |> Interaction.put_resp_type_message()
      end
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
