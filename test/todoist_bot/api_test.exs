defmodule TodoistBotTest.Api do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts TodoistBot.Api.init([])

  test "404 on unknown endpoint" do
    conn = conn(:get, "authorise")

    conn = TodoistBot.Api.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Resource not found"
  end

  test "/authorize/ redirects user to todoist" do
    conn = conn(:get, "/authorize?uuid=666.test")

    conn = TodoistBot.Api.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 301
    assert conn.resp_body == "You're being redirected..."

    assert get_resp_header(conn, "location") == [
             "https://todoist.com/oauth/authorize?client_id=test&scope=data:read_write&state=666.test"
           ]
  end

  # test "/authorization/finish returns 200 OK" do
  #   conn = conn(:get, "/authorization/finish")

  #   conn = TodoistBot.Api.call(conn, @opts)
  #   assert conn.state == :sent
  #   assert conn.status == 200
  #   assert conn.resp_body == "Thanks"
  # end
end
