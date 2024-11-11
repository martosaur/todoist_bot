defmodule TodoistBotTest.Commands do
  use TodoistBot.DataCase, async: false
  alias TodoistBot.Interaction
  alias TodoistBot.Commands
  alias TodoistBot.User
  alias TodoistBot.Repo

  test "/help" do
    i =
      %Interaction{
        request: %Interaction.Request{
          text: "/help"
        },
        response: %Interaction.Response{
          chat_id: 111
        },
        user: %User{}
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
        user: %User{}
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
        user: %User{
          auth_state: "auth_state"
        }
      }
      |> Commands.match()

    assert i.response.text == "Please authorize this bot to access your account"
    assert i.response.type == :message
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %{
             inline_keyboard: [
               [
                 %{
                   text: "Authorize on Todoist",
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

  test "callback query /logout.confirm.yes" do
    user = %User{telegram_id: 42} |> Repo.insert!()

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
        user: user
      }
      |> Commands.match()

    assert i.response.text == "Who are you? Do I know you?"
    assert i.response.type == :edit_text
    assert i.response.chat_id == 111
    assert i.response.reply_markup == nil
    assert i.response.callback_query_id == 333
    assert i.response.answer_callback_query_text == nil
    assert i.response.message_id == 222
    assert i.response.parse_mode == nil
    refute Repo.reload(i.user)
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
        user: %User{
          auth_code: "auth_code"
        }
      }
      |> Commands.match()

    assert i.response.text ==
             "Are you sure you want to logout and disappear without a trace from this bot's life?"

    assert i.response.type == :message
    assert i.response.chat_id == 111

    assert i.response.reply_markup == %{
             inline_keyboard: [
               [
                 %{
                   text: "Yes",
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
