defmodule FalconBotTest do
  use ExUnit.Case
  doctest FalconBot

  test "greets the world" do
    assert FalconBot.hello() == :world
  end
end
