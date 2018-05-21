defmodule TodoistBot.Commands do
  alias TodoistBot.Interaction
  require Logger

  def match(%Interaction{} = i) do
    Logger.info(inspect(i))

    if Interaction.callback_query?(i) do
      case i.request.callback do
        "/unauthorized.settings" ->
          i
          |> Interaction.add_resp_inline_keyboard()
          |> Interaction.add_resp_inline_keyboard_row()
          |> Interaction.add_resp_inline_keyboard_callback_button(:back, "/unauthorized.back")
          |> render_language_menu("/unauthorized.")
          |> Interaction.put_resp_type_edit_markup()

        "/unauthorized.back" ->
          i
          |> request_authorization()
          |> Interaction.put_resp_type_edit_markup()

        "/unauthorized.lan." <> language ->
          i
          |> Interaction.put_user_state(language: language)
          |> Interaction.put_resp_answer_callback_text(:language_changed)
          |> request_authorization()
          |> Interaction.put_resp_type_edit_text()

        "/lan." <> language ->
          i
          |> Interaction.put_user_state(language: language)
          |> Interaction.put_resp_answer_callback_text(:language_changed)
          |> Interaction.put_resp_type_answer_callback()

        "/logout.confirm.yes" ->
          i
          |> Interaction.put_resp_text(:logout_success_text)
          |> Interaction.set_user_to_delete()
          |> Interaction.put_resp_type_edit_text()
      end
    else
      cond do
        Interaction.command?(i, "/settings") ->
          i
          |> Interaction.put_resp_text(:settings_menu_text)
          |> Interaction.add_resp_inline_keyboard()
          |> render_language_menu("/")
          |> Interaction.put_resp_type_message()

        Interaction.command?(i, "/help") ->
          i
          |> Interaction.put_resp_text(:help_text)
          |> Interaction.put_resp_parse_mode_markdown()
          |> Interaction.put_resp_type_message()

        Interaction.command?(i, "/about") ->
          i
          |> Interaction.put_resp_text(:about_text)
          |> Interaction.put_resp_parse_mode_markdown()
          |> Interaction.put_resp_type_message()

        Interaction.command?(i, "/logout") ->
          i
          |> Interaction.put_resp_text(:logout_confirm_text)
          |> Interaction.add_resp_inline_keyboard()
          |> Interaction.add_resp_inline_keyboard_row()
          |> Interaction.add_resp_inline_keyboard_callback_button(
            :logout_confirm_yes_button,
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
          |> Interaction.put_resp_text(:empty_input_text)
          |> Interaction.put_resp_type_message()

        true ->
          i
          |> request_authorization()
          |> Interaction.put_resp_type_message()
      end
    end
  end

  defp request_authorization(%Interaction{} = i) do
    i
    |> Interaction.put_resp_text(:authorization_request_text)
    |> Interaction.add_resp_inline_keyboard()
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_link_button(
      :authorization_request_button,
      "#{TodoistBot.Config.app_host()}authorize?uuid=#{i.user.auth_state}&language=#{
        i.user.language
      }"
    )
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_callback_button(
      :settings_button,
      "/unauthorized.settings"
    )
  end

  defp render_language_menu(%Interaction{} = i, prefix) do
    TodoistBot.Strings.get_supported_languages()
    |> Enum.chunk_every(2)
    |> Enum.reduce(i, &add_language_row_to_keyboard(prefix, &1, &2))
  end

  defp add_language_row_to_keyboard(prefix, [{s1, l1}, {s2, l2}], acc) do
    acc
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_callback_button(s1, prefix <> "lan." <> l1)
    |> Interaction.add_resp_inline_keyboard_callback_button(s2, prefix <> "lan." <> l2)
  end

  defp add_language_row_to_keyboard(prefix, [{s1, l1}], acc) do
    acc
    |> Interaction.add_resp_inline_keyboard_row()
    |> Interaction.add_resp_inline_keyboard_callback_button(s1, prefix <> "lan." <> l1)
  end
end
