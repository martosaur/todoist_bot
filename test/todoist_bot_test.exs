defmodule TodoistBotTest do
  use ExUnit.Case
  doctest TodoistBot

  test "greets the world" do
    assert TodoistBot.hello() == :world
  end
end
