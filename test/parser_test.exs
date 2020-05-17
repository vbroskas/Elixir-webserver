defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parser
  # alias in module you want to test
  alias Servy.Parser

  # to run a test file use: mix test test/servy_test.exs

  test "parases a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]

    headers = Parser.parse_headers(header_lines)

    assert headers == %{"A" => "1", "B" => "2"}
  end
end
