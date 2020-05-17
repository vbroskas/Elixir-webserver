defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  # to run a test file use: mix test test/servy_test.exs

  test "greets the world" do
    # assert Servy.hello() == :world
    assert 2 + 2 == 4
  end
end
