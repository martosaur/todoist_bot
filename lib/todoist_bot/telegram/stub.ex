defmodule TodoistBot.Telegram.API.Stub do
  @behaviour TodoistBot.Telegram.API

  @impl true
  def request(%{url: %URI{path: "bot{token}/deleteWebhook"}}) do
    {:ok,
     %Req.Response{
       status: 200,
       headers: %{
         "access-control-allow-methods" => ["GET, POST, OPTIONS"],
         "access-control-allow-origin" => ["*"],
         "access-control-expose-headers" => ["Content-Length,Content-Type,Date,Server,Connection"],
         "connection" => ["keep-alive"],
         "content-type" => ["application/json"],
         "date" => ["Mon, 28 Oct 2024 00:15:12 GMT"],
         "server" => ["nginx/1.18.0"],
         "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"]
       },
       body: %{
         "description" => "Webhook was deleted",
         "ok" => true,
         "result" => true
       },
       trailers: %{},
       private: %{}
     }}
  end

  @impl true
  def request(%{url: %URI{path: "bot{token}/setWebhook"}}) do
    {:ok,
     %Req.Response{
       status: 200,
       headers: %{
         "access-control-allow-methods" => ["GET, POST, OPTIONS"],
         "access-control-allow-origin" => ["*"],
         "access-control-expose-headers" => ["Content-Length,Content-Type,Date,Server,Connection"],
         "connection" => ["keep-alive"],
         "content-type" => ["application/json"],
         "date" => ["Mon, 28 Oct 2024 00:14:32 GMT"],
         "server" => ["nginx/1.18.0"],
         "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"]
       },
       body: %{"description" => "Webhook was set", "ok" => true, "result" => true},
       trailers: %{},
       private: %{}
     }}
  end

  @impl true
  def request(%{url: %URI{path: "bot{token}/sendMessage"}}) do
    {:ok,
     %Req.Response{
       status: 200,
       headers: %{
         "access-control-allow-methods" => ["GET, POST, OPTIONS"],
         "access-control-allow-origin" => ["*"],
         "access-control-expose-headers" => ["Content-Length,Content-Type,Date,Server,Connection"],
         "connection" => ["keep-alive"],
         "content-type" => ["application/json"],
         "date" => ["Mon, 28 Oct 2024 00:45:18 GMT"],
         "server" => ["nginx/1.18.0"],
         "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"]
       },
       body: %{
         "ok" => true,
         "result" => %{
           "chat" => %{
             "first_name" => "Foo",
             "id" => 123_123,
             "type" => "private",
             "username" => "bar"
           },
           "date" => 1_730_076_318,
           "from" => %{
             "first_name" => "todoiststagingbot",
             "id" => 597_799_359,
             "is_bot" => true,
             "username" => "todoiststagingbot"
           },
           "message_id" => 532,
           "text" => "FOOBAR"
         }
       },
       trailers: %{},
       private: %{}
     }}
  end
end
