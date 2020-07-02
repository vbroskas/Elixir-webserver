defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounter, as: Counter

  test "reports counts of missing path requests" do
    IO.puts("HERE")
    Counter.start()

    Counter.four_oh_four_found("/bigfoot")
    Counter.four_oh_four_found("/nessie")
    Counter.four_oh_four_found("/nessie")
    Counter.four_oh_four_found("/bigfoot")
    Counter.four_oh_four_found("/nessie")

    assert Counter.get_count("/nessie") == 3
    assert Counter.get_count("/bigfoot") == 2

    assert Counter.get_counts() == %{
             "/bigfoot" => 2,
             "/nessie" => 3,
             "/firstBad" => 3,
             "/secondBad" => 1
           }
  end
end
