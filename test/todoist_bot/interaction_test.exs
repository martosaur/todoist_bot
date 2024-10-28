defmodule TodoistBotTest.Interaction do
  use ExUnit.Case, async: true
  alias TodoistBot.Interaction

  test "new: create interaction from callback query" do
    update = %{
      "callback_query" => %{
        "data" => "/lan.en",
        "from" => %{
          "first_name" => "abc",
          "id" => 123,
          "last_name" => "abc",
          "username" => "abc"
        },
        "id" => "456",
        "inline_message_id" => nil,
        "message" => %{
          "audio" => nil,
          "caption" => nil,
          "channel_chat_created" => nil,
          "chat" => %{
            "first_name" => "abc",
            "id" => 789,
            "last_name" => "abc",
            "photo" => nil,
            "title" => nil,
            "type" => "private",
            "username" => "abc"
          },
          "contact" => nil,
          "date" => 1_526_201_003,
          "delete_chat_photo" => nil,
          "document" => nil,
          "edit_date" => nil,
          "entities" => nil,
          "forward_date" => nil,
          "forward_from" => nil,
          "forward_from_chat" => nil,
          "from" => %{
            "first_name" => "bot",
            "id" => 012,
            "last_name" => nil,
            "username" => "bot"
          },
          "group_chat_created" => nil,
          "left_chat_member" => nil,
          "location" => nil,
          "message_id" => 666,
          "migrate_from_chat_id" => nil,
          "migrate_to_chat_id" => nil,
          "new_chat_member" => nil,
          "new_chat_photo" => [],
          "new_chat_title" => nil,
          "photo" => [],
          "pinned_message" => nil,
          "reply_to_message" => nil,
          "sticker" => nil,
          "supergroup_chat_created" => nil,
          "text" => "Language settings",
          "venue" => nil,
          "video" => nil,
          "voice" => nil
        }
      },
      "channel_post" => nil,
      "chosen_inline_result" => nil,
      "edited_message" => nil,
      "inline_query" => nil,
      "message" => nil,
      "update_id" => 9_999_999
    }

    i = Interaction.new(update)

    assert i.request.raw == update
    assert i.request.chat_id == 789
    assert i.request.text == ""
    assert i.request.callback == "/lan.en"

    assert i.response.chat_id == 789
    assert i.response.text == ""
    assert i.response.type == :none
    assert i.response.callback_query_id == "456"
    assert i.response.message_id == 666

    assert i.user.telegram_id == 123
    assert i.user.last_chat_id == 789

    assert i.user.raw == %{
             "first_name" => "abc",
             "id" => 123,
             "last_name" => "abc",
             "username" => "abc"
           }
  end

  test "new: create interaction from regular message" do
    update = %{
      "callback_query" => nil,
      "channel_post" => nil,
      "chosen_inline_result" => nil,
      "edited_message" => nil,
      "inline_query" => nil,
      "message" => %{
        "audio" => nil,
        "caption" => nil,
        "channel_chat_created" => nil,
        "chat" => %{
          "first_name" => "abc",
          "id" => 111,
          "last_name" => "abc",
          "photo" => nil,
          "title" => nil,
          "type" => "private",
          "username" => "abc"
        },
        "contact" => nil,
        "date" => 1_526_201_003,
        "delete_chat_photo" => nil,
        "document" => nil,
        "edit_date" => nil,
        "entities" => [%{"length" => 9, "offset" => 0, "type" => "bot_command"}],
        "forward_date" => nil,
        "forward_from" => nil,
        "forward_from_chat" => nil,
        "from" => %{
          "first_name" => "abc",
          "id" => 222,
          "last_name" => "abc",
          "username" => "abc"
        },
        "group_chat_created" => nil,
        "left_chat_member" => nil,
        "location" => nil,
        "message_id" => 333,
        "migrate_from_chat_id" => nil,
        "migrate_to_chat_id" => nil,
        "new_chat_member" => nil,
        "new_chat_photo" => [],
        "new_chat_title" => nil,
        "photo" => [],
        "pinned_message" => nil,
        "reply_to_message" => nil,
        "sticker" => nil,
        "supergroup_chat_created" => nil,
        "text" => "/settings",
        "venue" => nil,
        "video" => nil,
        "voice" => nil
      },
      "update_id" => 444
    }

    i = Interaction.new(update)

    assert i.request.raw == update
    assert i.request.chat_id == 111
    assert i.request.text == "/settings"
    assert i.request.callback == ""

    assert i.response.chat_id == 111
    assert i.response.text == ""
    assert i.response.type == :none
    assert i.response.callback_query_id == nil
    assert i.response.message_id == nil

    assert i.user.telegram_id == 222
    assert i.user.last_chat_id == 111

    assert i.user.raw == %{
             "first_name" => "abc",
             "id" => 222,
             "last_name" => "abc",
             "username" => "abc"
           }
  end

  test "authorized? true" do
    b =
      %Interaction{
        user: %Interaction.User{
          auth_code: "test"
        }
      }
      |> Interaction.authorized?()

    assert b == true
  end

  test "authorized? false" do
    b =
      %Interaction{
        user: %Interaction.User{
          auth_code: ""
        }
      }
      |> Interaction.authorized?()

    assert b == false
  end

  test "callback_query? true" do
    b =
      %Interaction{
        request: %Interaction.Request{
          callback: "test"
        }
      }
      |> Interaction.callback_query?()

    assert b == true
  end

  test "callback_query? false" do
    b =
      %Interaction{
        request: %Interaction.Request{
          callback: ""
        }
      }
      |> Interaction.callback_query?()

    assert b == false
  end

  test "command?" do
    b =
      %Interaction{
        request: %Interaction.Request{
          text: ";kljkh"
        }
      }
      |> Interaction.command?(";kljkh")

    assert b == true
  end

  test "new_user_state: populates auth_state" do
    i =
      %Interaction{
        user: %Interaction.User{
          telegram_id: 111
        }
      }
      |> Interaction.new_user_state()

    "111." <> random = i.user.auth_state
    assert random != ""
  end

  test "put_user_state: normal" do
    i =
      %Interaction{
        user: %Interaction.User{
          telegram_id: 111
        }
      }
      |> Interaction.put_user_state(
        telegram_id: 222,
        last_chat_id: 333,
        language: "zh",
        auth_code: "code",
        access_token: "token"
      )

    assert i.user.telegram_id == 222
    assert i.user.last_chat_id == 333
    assert i.user.language == "zh"
    assert i.user.auth_code == "code"
    assert i.user.access_token == "token"
  end

  test "put_user_state: attribute does not exist" do
    i =
      %Interaction{
        user: %Interaction.User{
          telegram_id: 111
        }
      }
      |> Interaction.put_user_state(hello_world: "test")

    assert i == i
  end

  test "put_resp_text" do
    i =
      %Interaction{
        response: %Interaction.Response{
          text: "test"
        },
        user: %Interaction.User{
          language: "ru"
        }
      }
      |> Interaction.put_resp_text(:test)

    assert i.response.text == "тест"
  end

  test "put_resp_answer_callback_text" do
    i =
      %Interaction{
        response: %Interaction.Response{
          answer_callback_query_text: "test"
        },
        user: %Interaction.User{
          language: "pl"
        }
      }
      |> Interaction.put_resp_answer_callback_text(:test)

    assert i.response.answer_callback_query_text == "default_test"
  end

  test "put_resp_type_*" do
    i =
      %Interaction{
        response: %Interaction.Response{
          type: :none
        }
      }
      |> Interaction.put_resp_type_message()

    assert i.response.type == :message

    j = Interaction.put_resp_type_edit_markup(i)

    assert j.response.type == :edit_markup

    k = Interaction.put_resp_type_edit_text(i)

    assert k.response.type == :edit_text

    l = Interaction.put_resp_type_answer_callback(i)

    assert l.response.type == :answer_callback
  end

  test "add_resp_parse_mode_markup" do
    i =
      %Interaction{
        response: %Interaction.Response{}
      }
      |> Interaction.put_resp_parse_mode_markdown()

    assert i.response.parse_mode == "Markdown"
  end

  test "put_resp_inline_keyboard" do
    i =
      %Interaction{
        response: %Interaction.Response{reply_markup: nil}
      }
      |> Interaction.add_resp_inline_keyboard()

    assert %{inline_keyboard: []} = i.response.reply_markup
  end

  test "put_resp_inline_keyboard_row" do
    i =
      %Interaction{
        response: %Interaction.Response{
          reply_markup: %{inline_keyboard: []}
        }
      }
      |> Interaction.add_resp_inline_keyboard_row()

    assert i.response.reply_markup.inline_keyboard == [[]]

    j = Interaction.add_resp_inline_keyboard_row(i)

    assert j.response.reply_markup.inline_keyboard == [[], []]
  end

  test "add_resp_inline_keyboard_link_button" do
    i =
      %Interaction{
        response: %Interaction.Response{
          reply_markup: %{
            inline_keyboard: [[], []]
          }
        },
        user: %Interaction.User{}
      }
      |> Interaction.add_resp_inline_keyboard_link_button(:test, "https://example.com")

    assert i.response.reply_markup.inline_keyboard == [
             [],
             [%{text: "default_test", url: "https://example.com"}]
           ]
  end

  test "add_resp_inline_keyboard_callback_button" do
    i =
      %Interaction{
        response: %Interaction.Response{
          reply_markup: %{
            inline_keyboard: [[], []]
          }
        },
        user: %Interaction.User{}
      }
      |> Interaction.add_resp_inline_keyboard_callback_button(:test, "data")

    assert i.response.reply_markup.inline_keyboard == [
             [],
             [%{text: "default_test", callback_data: "data"}]
           ]
  end

  test "set_user_to_delete" do
    i =
      %Interaction{
        user: %Interaction.User{}
      }
      |> Interaction.set_user_to_delete()

    assert i.user.delete == true
  end

  test "put_user_from_db" do
    db_user = %Interaction.User{
      telegram_id: 111,
      last_chat_id: 0,
      auth_code: "valid code",
      auth_state: "valid state",
      access_token: "valid token"
    }

    i =
      %Interaction{
        user: %Interaction.User{
          telegram_id: 111,
          last_chat_id: 222,
          auth_code: "pew",
          auth_state: "pew",
          access_token: "pew",
          raw: %{a: 1},
          delete: true
        }
      }
      |> Interaction.put_user_from_db(db_user)

    assert i.user.telegram_id == 111
    assert i.user.last_chat_id == 222
    assert i.user.auth_code == "valid code"
    assert i.user.auth_state == "valid state"
    assert i.user.access_token == "valid token"
    assert i.user.raw == %{a: 1}
    assert i.user.delete == false
  end
end
