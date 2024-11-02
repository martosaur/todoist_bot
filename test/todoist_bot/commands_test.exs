defmodule TodoistBotTest.Commands do
  use ExUnit.Case, async: false
  alias TodoistBot.Interaction
  alias TodoistBot.Commands
  alias TodoistBot.Strings

  test "/help" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "/help"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %Interaction.User{}
      }
      |> Commands.match()

    assert i.response.text ==
             "/help - show this help\n/about - about this bot\n/logout - make this bot forget you\n"

    assert i.response.type == :message
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == "Markdown"
  end

  test "/about" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "/about"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %Interaction.User{}
      }
      |> Commands.match()

    assert "*Telegram for Todoist*" <> _ = i.response.text
    assert i.response.type == :message
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == "Markdown"
  end

  test "some text" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "hello world"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %Interaction.User{
          auth_state: "auth_state"
        }
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:authorization_request_text, "en")
    assert i.response.type == :message
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %{
             inline_keyboard: [
               [
                 %{
                   text: Strings.get_string(:authorization_request_button, "en"),
                   url: "https://localhost/authorize?uuid=auth_state"
                 }
               ],
               []
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == nil
  end

  test "callback query /unauthorized.back" do
    i =
      %Interaction{
        request: %Interaction.Request{
          callback: "/unauthorized.back"
        },
        response: %Interaction.Response{
          chat_id: 111,
          message_id: 222
        },
        user: %Interaction.User{
          auth_state: "auth_state"
        }
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:authorization_request_text, "en")
    assert i.response.type == :edit_markup
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %{
             inline_keyboard: [
               [
                 %{
                   text: Strings.get_string(:authorization_request_button, "en"),
                   url: "https://localhost/authorize?uuid=auth_state"
                 }
               ],
               []
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == 222
    assert i.response.parse_mode == nil
  end

  test "callback query /logout.confirm.yes" do
    i =
      %Interaction{
        request: %Interaction.Request{
          callback: "/logout.confirm.yes"
        },
        response: %Interaction.Response{
          chat_id: 111,
          message_id: 222,
          callback_query_id: 333
        },
        user: %Interaction.User{}
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:logout_success_text, "en")
    assert i.response.type == :edit_text
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == 333
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == 222
    assert i.response.parse_mode == nil
    assert i.user.delete == true
  end

  test "/logout" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "/logout"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %Interaction.User{
          auth_code: "auth_code"
        }
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:logout_confirm_text, "en")
    assert i.response.type == :message
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %{
             inline_keyboard: [
               [
                 %{
                   text: Strings.get_string(:logout_confirm_yes_button, "en"),
                   callback_data: "/logout.confirm.yes"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == nil
  end
end
