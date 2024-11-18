defmodule TodoistBotTest.Interaction do
  use TodoistBot.DataCase, async: false
  alias TodoistBot.Interaction
  alias TodoistBot.User

  describe "from_update" do
    test "callback query" do
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

      assert {:ok, interaction} = Interaction.from_update(update)

      assert %Interaction{
               request: %{
                 chat_id: 789,
                 text: nil,
                 callback: "/lan.en"
               },
               response: %{
                 chat_id: 789,
                 text: nil,
                 type: nil,
                 callback_query_id: "456",
                 message_id: 666
               },
               user: nil
             } = interaction
    end

    test "regular message" do
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

      assert {:ok, interaction} = Interaction.from_update(update)

      assert %Interaction{
               request: %{
                 chat_id: 111,
                 text: "/settings",
                 callback: nil
               },
               response: %{
                 chat_id: 111,
                 text: nil,
                 type: nil,
                 callback_query_id: nil,
                 message_id: nil
               },
               user: nil
             } = interaction
    end
  end

  describe "load_user/2" do
    test "creates new user" do
      interaction = %Interaction{request: %Interaction.Request{}}

      update = %{
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          }
        }
      }

      assert {:ok,
              %Interaction{
                user: %User{
                  telegram_id: 222,
                  last_chat_id: 111,
                  auth_state: "222." <> _
                }
              }} = Interaction.load_user(interaction, update)
    end

    test "updates existing user" do
      Repo.insert!(%User{telegram_id: 222, last_chat_id: 0, auth_state: "foo"})

      interaction = %Interaction{request: %Interaction.Request{}}

      update = %{
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          }
        }
      }

      assert {:ok,
              %Interaction{
                user: %User{
                  telegram_id: 222,
                  last_chat_id: 111,
                  auth_state: "foo"
                }
              }} = Interaction.load_user(interaction, update)
    end
  end

  describe "notification/2" do
    test "creates an interaction for chat_id" do
      assert %Interaction{
               user: nil,
               request: nil,
               response: %Interaction.Response{chat_id: "chat_id", text: "PSA", type: :message}
             } = Interaction.notification("chat_id", "PSA")
    end
  end

  describe "put_rest_text/2" do
    test "put_resp_text" do
      i =
        %Interaction{
          response: %Interaction.Response{
            text: "test"
          },
          user: %User{}
        }
        |> Interaction.put_resp_text("test")

      assert i.response.text == "test"
    end
  end

  describe "put_rest_type/2" do
    test "put_resp_type" do
      i =
        %Interaction{
          response: %Interaction.Response{
            type: :none
          }
        }
        |> Interaction.put_resp_type(:message)

      assert i.response.type == :message

      j = Interaction.put_resp_type(i, :edit_markup)

      assert j.response.type == :edit_markup

      k = Interaction.put_resp_type(i, :edit_text)

      assert k.response.type == :edit_text
    end
  end

  describe "misc" do
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
          user: %User{}
        }
        |> Interaction.add_resp_inline_keyboard_link_button("test text", "https://example.com")

      assert i.response.reply_markup.inline_keyboard == [
               [],
               [%{text: "test text", url: "https://example.com"}]
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
          user: %User{}
        }
        |> Interaction.add_resp_inline_keyboard_callback_button("test_text", "data")

      assert i.response.reply_markup.inline_keyboard == [
               [],
               [%{text: "test_text", callback_data: "data"}]
             ]
    end
  end
end
