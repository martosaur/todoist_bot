defmodule TodoistBot.ProcessorTest do
  use TodoistBot.DataCase, async: false

  alias TodoistBot.Processor
  alias TodoistBot.Interaction
  alias TodoistBot.User
  alias TodoistBot.Repo
  alias TodoistBot.Telegram

  import Mox

  setup :verify_on_exit!

  describe "process_message/1" do
    test "new chat" do
      update = %{
        "callback_query" => nil,
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          },
          "text" => "Hello world!"
        },
        "update_id" => 444
      }

      expect(Telegram.API.Mock, :request, fn req ->
        assert %{
                 url: %URI{path: "bot{token}/sendMessage"},
                 method: :post,
                 options: %{
                   json: %{
                     text: "Please authorize this bot to access your account",
                     chat_id: 111,
                     reply_markup: %{
                       inline_keyboard: [
                         [
                           %{
                             text: "Authorize on Todoist",
                             url: "https://localhost/authorize?uuid=222." <> _
                           }
                         ],
                         []
                       ]
                     }
                   },
                   path_params: [token: "mytoken"],
                   path_params_style: :curly,
                   base_url: "https://api.telegram.org"
                 }
               } = req
      end)

      assert Processor.process_message(update)

      assert %User{
               telegram_id: 222,
               last_chat_id: 111,
               auth_code: nil,
               auth_state: "222." <> _,
               access_token: nil
             } = Repo.get(User, "222")
    end

    test "unauthorized: simple command" do
      user =
        Repo.insert!(%User{
          telegram_id: 222,
          last_chat_id: 111,
          auth_state: "222.random"
        })

      update = %{
        "callback_query" => nil,
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          },
          "text" => "/help"
        },
        "update_id" => 444
      }

      expect(Telegram.API.Mock, :request, fn req ->
        assert %{
                 url: %URI{path: "bot{token}/sendMessage"},
                 method: :post,
                 options: %{
                   json: %{
                     text: "/help - show this help\n/about - about this bot\n" <> _,
                     chat_id: 111,
                     parse_mode: "Markdown"
                   }
                 }
               } = req
      end)

      assert Processor.process_message(update)
    end

    test "authorized: simple command" do
      user =
        Repo.insert!(%User{
          telegram_id: 222,
          last_chat_id: 111,
          auth_state: "222.random",
          access_token: "user_token",
          auth_code: "auth_code"
        })

      update = %{
        "callback_query" => nil,
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          },
          "text" => "/help"
        },
        "update_id" => 444
      }

      expect(Telegram.API.Mock, :request, fn req ->
        assert %{
                 url: %URI{path: "bot{token}/sendMessage"},
                 method: :post,
                 options: %{
                   json: %{
                     text: "/help - show this help\n/about - about this bot\n" <> _,
                     chat_id: 111,
                     parse_mode: "Markdown"
                   }
                 }
               } = req
      end)

      assert Processor.process_message(update)
    end

    test "logout" do
      user =
        Repo.insert!(%User{
          telegram_id: 222,
          last_chat_id: 111,
          auth_state: "222.random"
        })

      update = %{
        "callback_query" => nil,
        "message" => %{
          "chat" => %{
            "id" => 111
          },
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          },
          "text" => "/logout"
        },
        "update_id" => 444
      }

      expect(Telegram.API.Mock, :request, fn req ->
        assert %{
                 url: %URI{path: "bot{token}/sendMessage"},
                 method: :post,
                 options: %{
                   json: %{
                     text: "Are you sure" <> _,
                     chat_id: 111,
                     reply_markup: %{
                       inline_keyboard: [
                         [
                           %{
                             text: "Yes",
                             callback_data: "/logout.confirm.yes"
                           }
                         ]
                       ]
                     }
                   }
                 }
               } = req
      end)

      assert Processor.process_message(update)
    end

    test "confirm logout" do
      user =
        Repo.insert!(%User{
          telegram_id: 222,
          last_chat_id: 111,
          auth_state: "222.random"
        })

      update = %{
        "callback_query" => %{
          "data" => "/logout.confirm.yes",
          "from" => %{
            "first_name" => "abc",
            "id" => 222,
            "last_name" => "abc",
            "username" => "abc"
          },
          "id" => "456",
          "inline_message_id" => nil,
          "message" => %{
            "chat" => %{
              "id" => 111
            },
            "message_id" => 666
          }
        },
        "message" => nil,
        "update_id" => 444
      }

      pid = self()

      expect(Telegram.API.Mock, :request, 2, fn req -> send(pid, req) end)
      assert Processor.process_message(update)

      assert_receive %{
        url: %URI{path: "bot{token}/editMessageText"},
        method: :post,
        options: %{
          json: %{
            text: "Who are you? Do I know you?",
            chat_id: 111,
            message_id: 666
          }
        }
      }

      assert_receive %{
        url: %URI{path: "bot{token}/answerCallbackQuery"},
        method: :post,
        options: %{
          json: %{
            callback_query_id: "456"
          }
        }
      }
    end
  end
end
