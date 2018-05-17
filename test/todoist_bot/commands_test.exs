defmodule TodoistBotTest.Commands do
  use ExUnit.Case, async: true
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

    assert i.response.text == Strings.get_string(:help_text, "en")
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
        user: %Interaction.User{
          language: "ru"
        }
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:about_text, "ru")
    assert i.response.type == :message
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == "Markdown"
  end

  test "/settings" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "/settings"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %Interaction.User{}
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:settings_menu_text, "en")
    assert i.response.type == :message
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:en, "en"),
                   callback_data: "/lan.en"
                 },
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:pl, "pl"),
                   callback_data: "/lan.pl"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:ru, "ru"),
                   callback_data: "/lan.ru"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == nil
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

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:authorization_request_button, "en"),
                   url: "http://example.com/authorize?uuid=auth_state&language=en"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:settings_button, "en"),
                   callback_data: "/unauthorized.settings"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == nil
    assert i.response.parse_mode == nil
  end

  test "callback query /unauthorized.settings" do
    i =
      %Interaction{
        request: %Interaction.Request{
          callback: "/unauthorized.settings"
        },
        response: %Interaction.Response{
          chat_id: 111,
          message_id: 222
        },
        user: %Interaction.User{}
      }
      |> Commands.match()

    assert i.response.text == ""
    assert i.response.type == :edit_markup
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:back, "en"),
                   callback_data: "/unauthorized.back"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:en, "en"),
                   callback_data: "/unauthorized.lan.en"
                 },
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:pl, "pl"),
                   callback_data: "/unauthorized.lan.pl"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:ru, "ru"),
                   callback_data: "/unauthorized.lan.ru"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == 222
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

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:authorization_request_button, "en"),
                   url: "http://example.com/authorize?uuid=auth_state&language=en"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:settings_button, "en"),
                   callback_data: "/unauthorized.settings"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == nil
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == 222
    assert i.response.parse_mode == nil
  end

  test "callback query /unauthorized.lan.ru" do
    i =
      %Interaction{
        request: %Interaction.Request{
          callback: "/unauthorized.lan.ru"
        },
        response: %Interaction.Response{
          chat_id: 111,
          message_id: 222,
          callback_query_id: 333
        },
        user: %Interaction.User{
          auth_state: "auth_state",
          language: "en"
        }
      }
      |> Commands.match()

    assert i.response.text == Strings.get_string(:authorization_request_text, "ru")
    assert i.response.type == :edit_text
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:authorization_request_button, "ru"),
                   url: "http://example.com/authorize?uuid=auth_state&language=ru"
                 }
               ],
               [
                 %Nadia.Model.InlineKeyboardButton{
                   text: Strings.get_string(:settings_button, "ru"),
                   callback_data: "/unauthorized.settings"
                 }
               ]
             ]
           }

    assert i.response.callback_query_id == 333
    assert i.response.answer_callback_query_text == Strings.get_string(:language_changed, "ru")
    assert i.response.message_id == 222
    assert i.response.parse_mode == nil
  end

  test "callback query /lan.ru" do
    i =
      %Interaction{
        request: %Interaction.Request{
          callback: "/lan.ru"
        },
        response: %Interaction.Response{
          chat_id: 111,
          message_id: 222,
          callback_query_id: 333
        },
        user: %Interaction.User{
          language: "en"
        }
      }
      |> Commands.match()

    assert i.response.text == ""
    assert i.response.type == :answer_callback
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == 333
    assert i.response.answer_callback_query_text == Strings.get_string(:language_changed, "ru")
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
        user: %Interaction.User{
          language: "en"
        }
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

    assert i.response.reply_markup == %Nadia.Model.InlineKeyboardMarkup{
             inline_keyboard: [
               [
                 %Nadia.Model.InlineKeyboardButton{
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
